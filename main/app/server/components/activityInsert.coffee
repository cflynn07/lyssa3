_         = require 'underscore'
async     = require 'async'
uuid      = require 'node-uuid'
config    = require GLOBAL.appRoot + 'config/config'
ORM       = require GLOBAL.appRoot + 'components/oRM'
sequelize = ORM.setup()

activity  = ORM.model 'activity'

module.exports = (insertObj, app, req) ->

  #Required property checks
  if _.isUndefined(insertObj['type']) || (activity.rawAttributes['type'].values.indexOf(insertObj['type']) is -1)
    throw new Error('invalid activity type')

  if _.isUndefined(insertObj['clientUid']) || !_.isString(insertObj['clientUid'])
    throw new Error('clientUid activity property requried')

  #if _.isUndefined(insertObj['employeeUid']) || !_.isString(insertObj['employeeUid'])
  #  throw new Error('employeeUid activity property requried')

  asyncMethods = []

  #Async/parallel look up ids of resources to link

  #clientUid
  asyncMethods.push (callback) ->
    client = ORM.model 'client'
    client.find(
      where:
        uid: insertObj['clientUid']
    ).success (clientResult) ->
      if clientResult && !_.isUndefined(clientResult.id)
        insertObj['clientId'] = clientResult.id
        callback null, true
      else
        callback new Error('invalid clientUid')



  checkMethodHelper = (type) ->
    if !_.isUndefined(insertObj[type + 'Uid'])
      asyncMethods.push (callback) ->
        resource = ORM.model type
        resource.find(
          where:
            uid: insertObj[type + 'Uid']
        ).success (result) ->
          if (result && !_.isUndefined(result.id) && result.clientUid == insertObj['clientUid'])
            insertObj[type + 'Id'] = result.id
            callback null, true
          else
            callback new Error('invalid ' + type + 'Uid')

  checkMethodHelper 'template'
  checkMethodHelper 'revision'
  checkMethodHelper 'dictionary'
  checkMethodHelper 'dictionaryItem'
  checkMethodHelper 'employee'
  checkMethodHelper 'event'

  async.parallel asyncMethods, (err, results) ->

    #console.log 'insertObj'
    #console.log insertObj

    if err
      console.log 'activity create error: '
      console.log err
      return

    insertObj['uid'] = uuid.v4()

    activity.create(insertObj).success (activityObj) ->
      #console.log 'activityObj'
      #console.log activityObj

      #The person who did this action has READ it
      activityObj = JSON.parse(JSON.stringify(activityObj))
      activityObj.readState = true


      sequelize.query("INSERT INTO activitiesReadState VALUES (NULL, \'" + activityObj.employeeUid + "\', \'" + activityObj.uid + "\', \'" + activityObj.clientUid + "\')", null, {raw:true}).done (err, queryResults) ->
        if !_.isUndefined(req) and !_.isUndefined(req.io) and _.isFunction(req.io.join)
          if !_.isUndefined(req.session) and !_.isUndefined(req.session.user) and !_.isUndefined(req.session.user.clientUid)
            req.io.join activityObj.uid
            req.io.join req.session.user.uid + '-' + activityObj.uid

        roomName = activityObj.clientUid + '-postResources'
        app.io.room(roomName).broadcast 'resourcePost',
          apiCollectionName: 'activities'
          resourceName:      'activity'
          resource:          JSON.parse(JSON.stringify(activityObj))








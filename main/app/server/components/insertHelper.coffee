_      = require 'underscore'
async  = require 'async'
uuid   = require 'node-uuid'
config = require GLOBAL.appRoot + 'config/config'

module.exports = (apiCollectionName, clientUid, resource, objects, req, res, app, insertMethodCallback = false) ->
  #Give everyone their own brand new uid
  for object, key in objects
    objects[key]['uid'] = uuid.v4()

  #responseUids = []
  #console.log objects

  #Due to some silly nonsense and bad planning, 'objects' will always be an array of length 1 at this point
  item = objects[0]
  try
    resource.create(item).success (createdItem) ->

      responseUid = createdItem.uid

      if !_.isUndefined(app.io) and _.isFunction(app.io.room)
        roomName = clientUid + '-postResources'
        if !_.isUndefined req.query.silent
          if req.query.silent == 'true'
            silent = true
          else
            silent = false
        else
          if req.requestType == 'http'
            silent = true
          else
            silent = false

        #broadcast update if silent == false
        #SIO DEFAULT == false
        #HTTP DEFAULT == true
        if !silent && !_.isArray(req.body) #If bulk-post, no broadcast
          app.io.room(roomName).broadcast 'resourcePost',
            apiCollectionName: apiCollectionName
            resourceName:      resource.name
            resource:          JSON.parse(JSON.stringify(createdItem))

        if !_.isUndefined(req.io) and _.isFunction(req.io.join)
          if !_.isUndefined(req.session) and !_.isUndefined(req.session.user) and !_.isUndefined(req.session.user.clientUid)
            #for uid in responseUids
            req.io.join(responseUid)


      if insertMethodCallback is false
        config.apiSuccessPostResponse res, responseUid
        #res.jsonAPIRespond(code: 201, message: config.apiResponseCodes[201], uids: responseUids)
      else
        insertMethodCallback(responseUid)

  catch error
    console.log 'error insertHelper'
    console.log error

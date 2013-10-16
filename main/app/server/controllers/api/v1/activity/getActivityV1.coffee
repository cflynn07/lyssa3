_         = require 'underscore'
async     = require 'async'
config    = require GLOBAL.appRoot + 'config/config'
apiAuth   = require GLOBAL.appRoot + 'components/apiAuth'
apiExpand = require GLOBAL.appRoot + 'components/apiExpand'
ORM       = require GLOBAL.appRoot + 'components/oRM'
sequelize = ORM.setup()

module.exports = (app) ->

  tempRespondHolder = () ->
  expandWithReadResult = (req, response) ->
    if response.code == 200 && response.response.data.length > 0
      uids = []
      data = response.response.data
      if !_.isArray(data)
        data = [data]

      for item in data
        #console.log item
        uids.push '\'' + item.uid + '\''

        #Join special rooms
        if !_.isUndefined(req.io) and _.isFunction(req.io.join)
          if !_.isUndefined(req.session) and !_.isUndefined(req.session.user) and !_.isUndefined(req.session.user.clientUid)
            req.io.join req.session.user.uid + '-' + item.uid


      if _.isArray(response.response.data)
        for activityItem, key in response.response.data
          response.response.data[key].readState = false
      else
        response.response.data.readState = false


      #console.log "SELECT * FROM activitiesReadState WHERE activityUid in (" + uids.join(',') + ")"
      sequelize.query("SELECT * FROM activitiesReadState WHERE employeeUid = \'" + req.session.user.uid + "\' AND activityUid in (" + uids.join(',') + ")", null, {raw:true}).done (err, queryReslts) ->
        if _.isArray(response.response.data)
          for readStateItem in queryReslts
            for activityItem, key in response.response.data
              if activityItem.uid == readStateItem.activityUid
                response.response.data[key].readState = true
                break;
        else
          for readStateItem in queryReslts
            if response.response.data.uid == readStateItem.activityUid
              response.response.data.readState = true
              break;
        tempRespondHolder(response)
    else
      tempRespondHolder(response)



  activity = ORM.model 'activity'

  app.get config.apiSubDir + '/v1/activity', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid

        switch userType
          when 'superAdmin'

            params =
              method: 'findAll'
              find: {}

            #How we attach 'read status' to each activity item for each user
            tempRespondHolder  = res.jsonAPIRespond
            res.jsonAPIRespond = (response) ->
              expandWithReadResult req, response

            apiExpand(req, res, activity, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  clientUid: clientUid

            #How we attach 'read status' to each activity item for each user
            tempRespondHolder  = res.jsonAPIRespond
            res.jsonAPIRespond = (response) ->
              expandWithReadResult req, response

            apiExpand(req, res, activity, params)

    ]

  app.get config.apiSubDir + '/v1/activity/:id', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid
        uids      = req.params.id.split ','

        switch userType
          when 'superAdmin'

            params =
              method: 'findAll'
              find:
                where:
                  uid: uids

            #How we attach 'read status' to each activity item for each user
            tempRespondHolder  = res.jsonAPIRespond
            res.jsonAPIRespond = (response) ->
              expandWithReadResult req, response

            apiExpand(req, res, activity, params)


          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  uid: uids
                  clientUid: clientUid

            #How we attach 'read status' to each activity item for each user
            tempRespondHolder  = res.jsonAPIRespond
            res.jsonAPIRespond = (response) ->
              expandWithReadResult req, response

            apiExpand(req, res, activity, params)
    ]


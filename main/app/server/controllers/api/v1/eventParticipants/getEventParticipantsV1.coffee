_         = require 'underscore'
async     = require 'async'
config    = require GLOBAL.appRoot + 'config/config'
apiAuth   = require GLOBAL.appRoot + 'components/apiAuth'
apiExpand = require GLOBAL.appRoot + 'components/apiExpand'
ORM       = require GLOBAL.appRoot + 'components/oRM'
sequelize = ORM.setup()

module.exports = (app) ->

  eventParticipant = ORM.model 'eventParticipant'

  app.get config.apiSubDir + '/v1/eventparticipants', (req, res) ->
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
            apiExpand(req, res, eventParticipant, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  clientUid: clientUid

            apiExpand(req, res, eventParticipant, params)

    ]





  updateAsViewedHelper = (employeeUid, result, req, res) ->

    if result.employeeUid == employeeUid
      eventParticipant.find(
        where:
          uid: result.uid
      ).success (resultEventParticipant) ->

        if _.isNull(resultEventParticipant.initialViewDateTime)

          resultEventParticipant.updateAttributes(
            initialViewDateTime: new Date()
          ).success () ->
            config.apiBroadcastPut eventParticipant, resultEventParticipant, app, req, res





  app.get config.apiSubDir + '/v1/eventparticipants/:id', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType    = req.session.user.type
        clientUid   = req.session.user.clientUid
        employeeUid = req.session.user.uid
        uids        = req.params.id.split ','

        switch userType
          when 'superAdmin'

            params =
              method: 'findAll'
              find:
                where:
                  uid: uids



            tempRespondHolder = res.jsonAPIRespond
            res.jsonAPIRespond = (result) ->
              if result.code == 200
                updateAsViewedHelper employeeUid, result.result, req, res
              tempRespondHolder result



            apiExpand(req, res, eventParticipant, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  uid:         uids
                  #employeeUid: employeeUid
                  clientUid:   clientUid



            tempRespondHolder = res.jsonAPIRespond
            res.jsonAPIRespond = (result) ->
              if result.code == 200
                updateAsViewedHelper employeeUid, result.response.data, req, res
              tempRespondHolder result



            apiExpand(req, res, eventParticipant, params)
    ]



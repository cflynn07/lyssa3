_         = require 'underscore'
async     = require 'async'
config    = require GLOBAL.appRoot + 'config/config'
apiAuth   = require GLOBAL.appRoot + 'components/apiAuth'
apiExpand = require GLOBAL.appRoot + 'components/apiExpand'
ORM       = require GLOBAL.appRoot + 'components/oRM'
sequelize = ORM.setup()

module.exports = (app) ->

  client = ORM.model 'client'

  app.get config.apiSubDir + '/v1/clients', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid

        switch userType
          when 'superAdmin'

            params =
              searchExpectsMultiple: true
              method:                'findAll'
              find:                  {}
            apiExpand(req, res, client, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              searchExpectsMultiple: true
              method:                'findAll'
              find:
                where:
                  uid: clientUid

            apiExpand(req, res, client, params)

    ]

  app.get config.apiSubDir + '/v1/clients/:id', (req, res) ->
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

            apiExpand(req, res, client, params)


          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            #These guys should never be able to request any client
            #other than their own. Therefore we don't even have to bother
            #running a query if uids.length > 1

            if uids.length > 1 or (uids[0] != clientUid)
              res.jsonAPIRespond config.errorResponse(401)

            else
              params =
                method: 'findAll'
                find:
                  where:
                    uid: uids

              apiExpand(req, res, client, params)
    ]


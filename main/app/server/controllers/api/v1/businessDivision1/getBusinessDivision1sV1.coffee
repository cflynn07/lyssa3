_         = require 'underscore'
async     = require 'async'
config    = require GLOBAL.appRoot + 'config/config'
apiAuth   = require GLOBAL.appRoot + 'components/apiAuth'
apiExpand = require GLOBAL.appRoot + 'components/apiExpand'
ORM       = require GLOBAL.appRoot + 'components/oRM'
sequelize = ORM.setup()

module.exports = (app) ->

  businessDivision1 = ORM.model 'businessDivision1'

  app.get config.apiSubDir + '/v1/businessDivision1s', (req, res) ->
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
            apiExpand(req, res, businessDivision1, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  clientUid: clientUid

            apiExpand(req, res, businessDivision1, params)

    ]



  app.get config.apiSubDir + '/v1/businessDivision1s/:id', (req, res) ->
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

            apiExpand(req, res, businessDivision1, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  uid: uids
                  clientUid: clientUid

            apiExpand(req, res, businessDivision1, params)
    ]

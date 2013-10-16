_         = require 'underscore'
async     = require 'async'
config    = require GLOBAL.appRoot + 'config/config'
apiAuth   = require GLOBAL.appRoot + 'components/apiAuth'
apiExpand = require GLOBAL.appRoot + 'components/apiExpand'
ORM       = require GLOBAL.appRoot + 'components/oRM'
sequelize = ORM.setup()

module.exports = (app) ->

  employee = ORM.model 'employee'

  app.get config.apiSubDir + '/v1/employees', (req, res) ->

#    d1 = Date.now()
#    sequelize.query("SELECT * FROM employees WHERE clientUid = '44cc27a5-af8b-412f-855a-57c8205d86f5'").success (myTableRows) ->
#      console.log(myTableRows.length)
#      console.log Date.now() - d1
#      res.json myTableRows
#    return

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
            apiExpand(req, res, employee, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  clientUid: clientUid

            apiExpand(req, res, employee, params)

    ]

  app.get config.apiSubDir + '/v1/employees/:id', (req, res) ->
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

            apiExpand(req, res, employee, params)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            params =
              method: 'findAll'
              find:
                where:
                  uid: uids
                  clientUid: clientUid

            apiExpand(req, res, employee, params)
    ]
_                         = require 'underscore'
async                     = require 'async'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
updateHelper              = require GLOBAL.appRoot + 'components/updateHelper'
sequelize                 = ORM.setup()


module.exports = (app) ->

  template = ORM.model 'template'
  revision = ORM.model 'revision'
  employee = ORM.model 'employee'


  app.put config.apiSubDir + '/v1/revisions', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType    = req.session.user.type
        clientUid   = req.session.user.clientUid
        employeeUid = req.session.user.uid

        switch userType
          when 'superAdmin'

            apiVerifyObjectProperties this, template, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    revision.find(
                      where:
                        uid: val
                    ).success (resultRevision) ->

                      if resultRevision
                        mapObj = {}
                        mapObj[val] = resultRevision
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'changeSummary': (val, objectKey, object, callback) ->
                  callback null,
                    success: true
                'scope': (val, objectKey, object, callback) ->
                  callback null,
                    success: true
                'finalized': (val, objectKey, object, callback) ->
                  if _.isUndefined val
                    callback null,
                      success: true
                    return

                  if val != 'true' && val != 'false' && (val is not true) && (val is not false)
                    callback null,
                      success: false
                      message:
                        finalized: 'invalid'
                    return

                  transVal = if (val == 'true' || (val is true)) then true else false

                  callback null,
                    success: true
                    transform: [objectKey, 'finalized', transVal]

            }, (objects) ->

              updateHelper revision, objects, req, res, app


          when 'clientSuperAdmin', 'clientAdmin'

            apiVerifyObjectProperties this, template, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    revision.find(
                      where:
                        clientUid: clientUid
                        uid: val
                    ).success (resultRevision) ->

                      if resultRevision
                        mapObj = {}
                        mapObj[val] = resultRevision
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'changeSummary': (val, objectKey, object, callback) ->
                  callback null,
                    success: true
                'scope': (val, objectKey, object, callback) ->
                  callback null,
                    success: true
                'finalized': (val, objectKey, object, callback) ->
                  if _.isUndefined val
                    callback null,
                      success: true
                    return

                  if val != 'true' && val != 'false' && (val is not true) && (val is not false)
                    callback null,
                      success: false
                      message:
                        finalized: 'invalid'
                    return

                  transVal = if (val == 'true' || (val is true)) then true else false

                  callback null,
                    success: true
                    transform: [objectKey, 'finalized', transVal]

            }, (objects) ->

              updateHelper revision, objects, req, res, app

          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]



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

  client     = ORM.model 'client'
  dictionary = ORM.model 'dictionary'
  employee   = ORM.model 'employee'

  app.put config.apiSubDir + '/v1/dictionaries', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid

        switch userType
          when 'superAdmin'


            apiVerifyObjectProperties this, dictionary, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    dictionary.find(
                      where:
                        uid: val
                    ).success (resultDictionary) ->

                      if resultDictionary
                        mapObj = {}
                        mapObj[val] = resultDictionary
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'name': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'clientUid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: true
                  else
                    callback null,
                      success: false
                      message:
                        clientUid: 'unknown'

                'deletedAt': (val, objectKey, object, callback) ->
                  callback null,
                    success: true

            }, (objects) ->

              #updateHelper objects, res
              updateHelper dictionary, objects, req, res, app


          when 'clientSuperAdmin', 'clientAdmin'


            apiVerifyObjectProperties this, dictionary, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    dictionary.find(
                      where:
                        clientUid: clientUid
                        uid: val
                    ).success (resultDictionary) ->

                      if resultDictionary
                        mapObj = {}
                        mapObj[val] = resultDictionary
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'name': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'clientUid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: true
                  else
                    callback null,
                      success: false
                      message:
                        clientUid: 'unknown'

                'deletedAt': (val, objectKey, object, callback) ->
                  callback null,
                    success: true


            }, (objects) ->

              #updateHelper objects, res
              updateHelper dictionary, objects, req, res, app

          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]



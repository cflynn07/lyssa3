_                         = require 'underscore'
async                     = require 'async'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
updateHelper              = require GLOBAL.appRoot + 'components/updateHelper'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
sequelize                 = ORM.setup()

module.exports = (app) ->

  client         = ORM.model 'client'
  dictionaryItem = ORM.model 'dictionaryItem'


  app.put config.apiSubDir + '/v1/dictionaryItems', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType    = req.session.user.type
        clientUid   = req.session.user.clientUid
        employeeUid = req.session.user.uid

        switch userType
          when 'superAdmin'


            apiVerifyObjectProperties this, dictionaryItem, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    dictionaryItem.find(
                      where:
                        uid: val
                    ).success (resultResource) ->

                      if resultResource
                        mapObj = {}
                        mapObj[val] = resultResource
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

            }, (objects) ->

              updateHelper dictionaryItem, objects, req, res, app



          when 'clientSuperAdmin', 'clientAdmin'


            apiVerifyObjectProperties this, dictionaryItem, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    dictionaryItem.find(
                      where:
                        clientUid: clientUid
                        uid: val
                    ).success (resultResource) ->

                      if resultResource
                        mapObj = {}
                        mapObj[val] = resultResource
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

            }, (objects) ->

              updateHelper dictionaryItem, objects, req, res, app


          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]



_                         = require 'underscore'
async                     = require 'async'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
insertHelper              = require GLOBAL.appRoot + 'components/insertHelper'
sequelize                 = ORM.setup()

module.exports = (app) ->

  client = ORM.model 'client'

  app.post config.apiSubDir + '/v1/clients', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->


        userType  = req.session.user.type
        clientUid = req.session.user.clientUid


        switch userType
          when 'superAdmin'

            insertMethod = (item, insertMethodCallback = false) ->

              apiVerifyObjectProperties this, client, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'name': (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          name: 'required'

                  'identifier': (val, objectKey, object, callback) ->
                    if val

                      #Make sure no duplicates
                      clients.find(
                        where:
                          identifier: val
                      ).success

                      callback null,
                        success: true

                    else
                      callback null,
                        success: false
                        message:
                          identifier: 'required'

                  'address1':      (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          address1: 'required'

                  'address2':      (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          address2: 'required'

                  'address3':      (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          address3: 'required'

                  'city':          (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          city: 'required'

                  'stateProvince': (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          stateProvince: 'required'

                  'country':       (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          country: 'required'

                  'telephone':     (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          telephone: 'required'

                  'fax':           (val, objectKey, object, callback) ->
                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          fax: 'required'

                  'businessDivision0Name': (val, objectKey, object, callback) ->
                    callback null,
                      success: true
                  'businessDivision1Name': (val, objectKey, object, callback) ->
                    callback null,
                      success: true
                  'businessDivision2Name': (val, objectKey, object, callback) ->
                    callback null,
                      success: true

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'clients', clientUid, client, objects, req, res, app, insertMethodCallback


            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod(req.body)


          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]



_                         = require 'underscore'
async                     = require 'async'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
activityInsert            = require GLOBAL.appRoot + 'components/activityInsert'
insertHelper              = require GLOBAL.appRoot + 'components/insertHelper'
sequelize                 = ORM.setup()


module.exports = (app) ->

  employee   = ORM.model 'employee'
  client     = ORM.model 'client'
  dictionary = ORM.model 'dictionary'


  app.post config.apiSubDir + '/v1/dictionaries', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType    = req.session.user.type
        clientUid   = req.session.user.clientUid
        employeeUid = req.session.user.uid

        switch userType
          when 'superAdmin'

            insertMethod = (item, insertMethodCallback = false) ->
              apiVerifyObjectProperties this, dictionary, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'name': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          name: 'required'

                  'clientUid': (val, objectKey, object, callback) ->

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    client.find(
                      where:
                        uid: testClientUid
                    ).success (resultClient) ->

                      if resultClient
                        mapObj = {}
                        mapObj[resultClient.uid] = resultClient

                        callback null,
                          success:   true
                          transform: [objectKey, 'clientUid', resultClient.uid]
                          uidMapping: mapObj
                      else
                        callback null,
                          success:   false
                          message:
                            clientUid: 'unknown'

              }, (objects) ->
                insertHelper 'dictionaries', clientUid, dictionary, objects, req, res, app, insertMethodCallback

            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod(req.body)


          when 'clientSuperAdmin', 'clientAdmin'

            insertMethod = (item, insertMethodCallback = false) ->

              apiVerifyObjectProperties this, dictionary, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'name': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          name: 'required'

                  'clientUid': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                      callback null,
                        success: false
                        message:
                          clientUid: 'unknown'
                      return

                    testClientUid = clientUid #if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    client.find(
                      where:
                        uid: testClientUid
                    ).success (resultClient) ->

                      mapObj = {}
                      mapObj[resultClient.uid] = resultClient

                      callback null,
                        success:   true
                        transform: [objectKey, 'clientUid', resultClient.uid]
                        uidMapping: mapObj

              }, (objects) ->
                insertHelper 'dictionaries', clientUid, dictionary, objects, req, res, app, insertMethodCallback


            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results



            else
              insertMethod req.body, (uid) ->

                #console.log 'uid'
                #console.log uid
                #return

                if _.isString(uid) && _.isUndefined(uid.code)

                  config.apiSuccessPostResponse res, uid

                  activityInsert {
                    type:          'createDictionary'
                    dictionaryUid: uid
                    employeeUid:   employeeUid
                    clientUid:     clientUid
                  }, app, req

                else
                  res.jsonAPIRespond uid



          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]

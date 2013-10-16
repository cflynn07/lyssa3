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

  employee       = ORM.model 'employee'
  client         = ORM.model 'client'
  dictionary     = ORM.model 'dictionary'
  dictionaryItem = ORM.model 'dictionaryItem'

  app.post config.apiSubDir + '/v1/dictionaryItems', (req, res) ->
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
              apiVerifyObjectProperties this, dictionaryItem, item, req, res, insertMethodCallback, {
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

                    callback null,
                      success:   true
                      transform: [objectKey, 'clientUid', testClientUid]

                  'dictionaryUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          dictionaryUid: 'required'
                      return

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    async.parallel [
                      (callback) ->
                        client.find(
                          where:
                            uid: testClientUid
                        ).success (resultClient) ->
                          callback null, resultClient

                      (callback) ->
                        dictionary.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultDictionary) ->
                          callback null, resultDictionary


                    ], (error, results) ->

                      resultClient      = results[0]
                      resultDictionary  = results[1]

                      if !resultDictionary
                        callback null,
                          success: false
                          message:
                            'dictionarUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultDictionary.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'dictionarUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultDictionary.uid]  = resultDictionary
                      mapObj[resultClient.uid]      = resultClient
                      callback null,
                        success: true

                        uidMapping: mapObj


              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'dictionaryItems', clientUid, dictionaryItem, objects, req, res, app, insertMethodCallback


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
              apiVerifyObjectProperties this, dictionaryItem, item, req, res, insertMethodCallback, {
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

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    callback null,
                      success:   true
                      transform: [objectKey, 'clientUid', testClientUid]

                  'dictionaryUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          dictionaryUid: 'required'
                      return

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    async.parallel [
                      (callback) ->
                        client.find(
                          where:
                            uid: testClientUid
                        ).success (resultClient) ->
                          callback null, resultClient

                      (callback) ->
                        dictionary.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultDictionary) ->
                          callback null, resultDictionary

                    ], (error, results) ->

                      resultClient      = results[0]
                      resultDictionary  = results[1]

                      if !resultDictionary
                        callback null,
                          success: false
                          message:
                            'dictionaryUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultDictionary.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'dictionaryUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultDictionary.uid]  = resultDictionary
                      mapObj[resultClient.uid]      = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj


              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'dictionaryItems', clientUid, dictionaryItem, objects, req, res, app, insertMethodCallback



            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod(req.body)



          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]

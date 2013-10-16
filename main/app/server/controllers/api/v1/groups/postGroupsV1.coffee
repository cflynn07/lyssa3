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

  group    = ORM.model 'group'
  template = ORM.model 'template'
  employee = ORM.model 'employee'
  client   = ORM.model 'client'
  revision = ORM.model 'revision'

  app.post config.apiSubDir + '/v1/groups', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid
        employeeUid = req.session.user.uid

        switch userType
          when 'superAdmin'

            insertMethod = (item, insertMethodCallback = false) ->
              apiVerifyObjectProperties this, group, item, req, res, insertMethodCallback, {
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

                  'ordinal': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          ordinal: 'required'

                  'description': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: true
                        transform: [objectKey, 'description', '']
                    else
                      callback null,
                        success: true


                  'clientUid': (val, objectKey, object, callback) ->

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    callback null,
                      success:   true
                      transform: [objectKey, 'clientUid', testClientUid]

                  'revisionUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          revisionUid: 'required'
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
                        revision.find(
                          where:
                            clientUid: testClientUid
                            uid: val
                        ).success (resultRevision) ->
                          callback null, resultRevision


                    ], (error, results) ->

                      resultClient   = results[0]
                      resultRevision = results[1]

                      if !resultRevision
                        callback null,
                          success: false
                          message:
                            'revisionUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultRevision.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'revisionUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultRevision.uid] = resultRevision
                      mapObj[resultClient.uid]   = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'groups', clientUid, group, objects, req, res, app, insertMethodCallback


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
              apiVerifyObjectProperties this, group, item, req, res, insertMethodCallback, {
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

                  'ordinal': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          ordinal: 'required'

                  'description': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: true
                        transform: [objectKey, 'description', '']
                    else
                      callback null,
                        success: true

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

                  'revisionUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          revisionUid: 'required'
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
                        revision.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultRevision) ->
                          callback null, resultRevision

                    ], (error, results) ->

                      resultClient   = results[0]
                      resultRevision = results[1]

                      if !resultRevision
                        callback null,
                          success: false
                          message:
                            'revisionUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultRevision.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'revisionUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultRevision.uid] = resultRevision
                      mapObj[resultClient.uid]   = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'groups', clientUid, group, objects, req, res, app, insertMethodCallback


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



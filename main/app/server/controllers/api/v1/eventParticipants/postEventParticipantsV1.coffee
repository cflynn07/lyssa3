_                         = require 'underscore'
async                     = require 'async'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
insertHelper              = require GLOBAL.appRoot + 'components/insertHelper'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
sequelize                 = ORM.setup()

module.exports = (app) ->

  employee         = ORM.model 'employee'
  client           = ORM.model 'client'
  event            = ORM.model 'event'
  eventParticipant = ORM.model 'eventParticipant'

  app.post config.apiSubDir + '/v1/eventparticipants', (req, res) ->
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
              apiVerifyObjectProperties this, eventParticipant, item, req, res, insertMethodCallback, {
                requiredProperties:

                  'clientUid': (val, objectKey, object, callback) ->

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    callback null,
                      success:   true
                      transform: [objectKey, 'clientUid', testClientUid]

                  'finalizedDateTime': (val, objectKey, object, callback) ->
                    callback null,
                      success: true


                  'initialViewDateTime': (val, objectKey, object, callback) ->
                    callback null,
                      success: true



                  'employeeUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          employeeUid: 'required'
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
                        employee.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultEmployee) ->
                          callback null, resultEmployee

                    ], (error, results) ->

                      resultClient      = results[0]
                      resultEmployee  = results[1]

                      if !resultEmployee
                        callback null,
                          success: false
                          message:
                            employeeUid: 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          message:
                            clientUid: 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultEmployee.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            employeeUid: 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultEmployee.uid]  = resultEmployee
                      mapObj[resultClient.uid]      = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'employeeUid', val]

                  'eventUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          eventUid: 'required'
                      return

                    if _.isUndefined object['employeeUid']
                      callback null,
                        success: true
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
                        event.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultEvent) ->
                          callback null, resultEvent

                      (callback) ->
                        eventParticipant.find(
                          where:
                            clientUid:   testClientUid
                            eventUid:    val
                            employeeUid: object['employeeUid']
                        ).success (resultEventParticipant) ->
                          callback null, resultEventParticipant

                    ], (error, results) ->

                      resultClient = results[0]
                      resultEvent  = results[1]
                      resultEventParticipant = results[2]

                      if resultEventParticipant
                        callback null,
                          success: false
                          message:
                            employeeUid: 'duplicate'
                        return

                      if !resultEvent
                        callback null,
                          success: false
                          message:
                            eventUid: 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          message:
                            clientUid: 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultEvent.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            eventUid: 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultEvent.uid]  = resultEvent
                      mapObj[resultClient.uid] = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'eventUid', val]

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'eventparticipants', clientUid, eventParticipant, objects, req, res, app, insertMethodCallback


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
              apiVerifyObjectProperties this, eventParticipant, item, req, res, insertMethodCallback, {
                requiredProperties:

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



                  'finalizedDateTime': (val, objectKey, object, callback) ->
                    callback null,
                      success: true


                  'initialViewDateTime': (val, objectKey, object, callback) ->
                    callback null,
                      success: true



                  'employeeUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          employeeUid: 'required'
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
                        employee.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultEmployee) ->
                          callback null, resultEmployee

                    ], (error, results) ->

                      resultClient      = results[0]
                      resultEmployee  = results[1]

                      if !resultEmployee
                        callback null,
                          success: false
                          message:
                            employeeUid: 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          message:
                            clientUid: 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultEmployee.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            employeeUid: 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultEmployee.uid]  = resultEmployee
                      mapObj[resultClient.uid]      = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'employeeUid', val]

                  'eventUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          eventUid: 'required'
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
                        event.find(
                          where:
                            clientUid: testClientUid
                            uid:       val
                        ).success (resultEvent) ->
                          callback null, resultEvent

                      (callback) ->
                        eventParticipant.find(
                          where:
                            clientUid:   testClientUid
                            eventUid:    val
                            employeeUid: object['employeeUid']
                        ).success (resultEventParticipant) ->
                          callback null, resultEventParticipant

                    ], (error, results) ->

                      resultClient           = results[0]
                      resultEvent            = results[1]
                      resultEventParticipant = results[2]

                      if resultEventParticipant
                        callback null,
                          success: false
                          message:
                            employeeUid: 'duplicate'
                        return

                      if !resultEvent
                        callback null,
                          success: false
                          message:
                            eventUid: 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          message:
                            clientUid: 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultEvent.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            eventUid: 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultEvent.uid]  = resultEvent
                      mapObj[resultClient.uid] = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'eventUid', val]

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'eventparticipants', clientUid, eventParticipant, objects, req, res, app, insertMethodCallback

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

_                         = require 'underscore'
async                     = require 'async'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
insertHelper              = require GLOBAL.appRoot + 'components/insertHelper'
activityInsert            = require GLOBAL.appRoot + 'components/activityInsert'
sequelize                 = ORM.setup()

redisClient               = require(GLOBAL.appRoot + 'components/redis').createClient()

module.exports = (app) ->

  employee         = ORM.model 'employee'
  client           = ORM.model 'client'
  event            = ORM.model 'event'
  revision         = ORM.model 'revision'
  eventParticipant = ORM.model 'eventParticipant'
  submission       = ORM.model 'submission'
  submissionField  = ORM.model 'submissionField'
  field            = ORM.model 'field'
  group            = ORM.model 'group'

  app.put config.apiSubDir + '/v1/submissionfields', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType    = req.session.user.type
        clientUid   = req.session.user.clientUid
        employeeUid = req.session.user.uid

      #  config.resourceModelUnknownFieldsExceptions['submission'] = ['submissionFields']
        helperInsertSubmissionField = (objects, finalCallback) ->
          object = objects[0]

          insertObj =
            uid:                 uuid.v4()
            fieldUid:            object.fieldUid
            eventParticipantUid: object.eventParticipantUid

          if !_.isUndefined(object.openResponseValue)
            insertObj.openResponseValue = object.openResponseValue

          if !_.isUndefined(object.sliderValue)
            insertObj.sliderValue = object.sliderValue

          if !_.isUndefined(object.yesNoValue)
            insertObj.yesNoValue = object.yesNoValue

          insertObj.fieldId            = object.uidMapping[object.fieldUid].id
          insertObj.eventParticipantId = object.uidMapping[object.eventParticipantUid].id
          insertObj.clientUid          = object.uidMapping[object.eventParticipantUid].clientUid
          insertObj.clientId           = object.uidMapping[object.eventParticipantUid].clientId

          #If exists, update -- else insert
          submissionField.find(
            where:
              eventParticipantUid: object.eventParticipantUid
              fieldUid:            object.fieldUid
              clientUid:           clientUid
          ).success (resultSubmissionField) ->

            if !resultSubmissionField
              submissionField.create(insertObj).success (resultSubmissionField) ->
                finalCallback()
            else
              resultSubmissionField.updateAttributes(insertObj).success (resultSubmissionField) ->
                finalCallback()
            insertObj = null
            object    = null




        helperCheckFieldUid = (val, objectKey, object, callback) ->
          eventParticipantUid = object['eventParticipantUid']
          fieldUid            = val

          if _.isUndefined(fieldUid)
            callback null,
              success: false
              message:
                fieldUid: 'required'
            return

          if _.isUndefined(eventParticipantUid)
            callback null,
              success: false
            return

          async.parallel [
            (subCallback) ->

              eventParticipant.find(
                where:
                  uid:         eventParticipantUid
                  clientUid:   clientUid
                  employeeUid: employeeUid
              ).success (resultEventParticipant) ->

                if !resultEventParticipant
                  subCallback null, [resultEventParticipant]
                  return

                event.find(
                  where:
                    uid: resultEventParticipant.eventUid
                    clientUid: clientUid
                ).success (resultEvent) ->
                  subCallback null, [resultEventParticipant, resultEvent]

            (subCallback) ->
              field.find(
                where:
                  uid: fieldUid
                  clientUid: clientUid
              ).success (resultField) ->

                if !resultField
                  subCallback null, [resultField]
                  return

                group.find(
                  where:
                    uid:       resultField.groupUid
                    clientUid: clientUid
                ).success (resultGroup) ->

                  if !resultGroup
                    subCallback null, [resultGroup]
                    return

                  revision.find(
                    where:
                      uid:       resultGroup.revisionUid
                      clientUid: clientUid
                  ).success (resultRevision) ->

                    if !resultRevision
                      subCallback null, [resultRevision]
                      return

                    subCallback null, [resultField, resultGroup, resultRevision]

          ], (err, results) ->
            resultEventParticipant = results[0][0]
            resultField            = results[1][0]
            if resultEventParticipant
              resultEvent            = results[0][1]

            if resultField
              resultGroup            = results[1][1]
              resultRevision         = results[1][2]

            messages = {}

            if !resultField
              messages.resultField = 'unknown'

            if !resultEventParticipant
              messages.resultEventParticipant = 'unknown'

            if !(resultEvent) || !(resultRevision) || (resultRevision.uid != resultEvent.revisionUid)
              messages.resultEventParticipant = 'unknown'
              messages.resultField            = 'unknown'

            if Object.keys(messages).length > 0

              callback null,
                success: false
                message: messages

            else
              mapObj = {}
              mapObj[resultEventParticipant.uid] = resultEventParticipant
              mapObj[resultField.uid]            = resultField
              mapObj[resultGroup.uid]            = resultGroup
              mapObj[resultRevision.uid]         = resultRevision
              mapObj[resultEvent.uid]            = resultEvent
              callback null,
                success: true
                transform: [objectKey, 'uidMapping', mapObj]
                uidMapping: mapObj

        helperCheckEventParticipantUid = (val, objectKey, object, callback) ->
          if _.isUndefined(val)
            callback null,
              success: false
              message:
                eventParticipantUid: 'required'
            return
          callback null,
            success: true
          return










        switch userType
          when 'superAdmin'

            insertMethod = (item, insertMethodCallback = false) ->
              apiVerifyObjectProperties this, submissionField, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'openResponseValue': (val, objectKey, object, callback) ->
                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          openResponseValue: 'required'

                  'sliderValue': (val, objectKey, object, callback) ->
                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          sliderValue: 'required'

                  'yesNoValue': (val, objectKey, object, callback) ->
                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          yesNoValue: 'required'

                  'clientUid': (val, objectKey, object, callback) ->
                    if !_.isUndefined(val)
                      callback null,
                        success: false
                        message:
                          clientUid: 'invalid'
                      return

                    callback null,
                      success: true

                  'fieldUid': (val, objectKey, object, callback) ->
                    helperCheckFieldUid val, objectKey, object, callback

                  'eventParticipantUid': (val, objectKey, object, callback) ->
                    helperCheckEventParticipantUid val, objectKey, object, callback

              }, (objects) ->
                helperInsertSubmissionField objects, () ->
                  res.jsonAPIRespond foo: 'bar'





            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results

            else
              insertMethod(req.body)

          when 'clientSuperAdmin', 'clientAdmin', 'clientDelegate', 'clientAuditor'

            insertMethod = (item, insertMethodCallback = false) ->
              apiVerifyObjectProperties this, submissionField, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'openResponseValue': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          openResponseValue: 'required'

                  'sliderValue': (val, objectKey, object, callback) ->
                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          sliderValue: 'required'

                  'yesNoValue': (val, objectKey, object, callback) ->
                    if !_.isUndefined val
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          yesNoValue: 'required'

                  'clientUid': (val, objectKey, object, callback) ->
                    if !_.isUndefined(val)
                      callback null,
                        success: false
                        message:
                          clientUid: 'invalid'
                      return

                    callback null,
                      success: true

                  'fieldUid': (val, objectKey, object, callback) ->
                    helperCheckFieldUid val, objectKey, object, callback

                  'eventParticipantUid': (val, objectKey, object, callback) ->
                    helperCheckEventParticipantUid val, objectKey, object, callback

              }, (objects) ->

                helperInsertSubmissionField objects, () ->
                  res.jsonAPIRespond foo: 'bar'





            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results

            else
              insertMethod(req.body)

    ]

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

  template = ORM.model 'template'
  employee = ORM.model 'employee'
  client   = ORM.model 'client'
  revision = ORM.model 'revision'
  group    = ORM.model 'group'

  app.post config.apiSubDir + '/v1/templates', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid
        uid       = req.session.user.uid


        insertChildRevisionAndGroupHelper = (uid, completeCallback) ->
          #Insert revision & 1st group
          template.find(
            where:
              uid: uid
          ).success (resultTemplate) ->

            revision.create({
              uid:           uuid.v4()

              changeSummary: ''
              scope:         ''
              finalized:     false

              clientUid:     resultTemplate.clientUid
              templateUid:   resultTemplate.uid
              employeeUid:   resultTemplate.employeeUid

              clientId:      resultTemplate.clientId
              templateId:    resultTemplate.id
              employeeId:    resultTemplate.employeeId

            }).success (resultRevision) ->

              group.create({
                uid:         uuid.v4()

                name:        'First Exercise Group'
                description: ''
                ordinal:     0

                clientUid:   resultRevision.clientUid
                revisionUid: resultRevision.uid

                clientId:    resultRevision.clientId
                revisionId:  resultRevision.id

              }).success (resultGroup) ->

                completeCallback(uid)






        #console.log req.session
        #console.log uid

        switch userType
          when 'superAdmin'

            insertMethod = (item, insertMethodCallback = false) ->
              apiVerifyObjectProperties this, template, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'name':        (val, objectKey, object, callback) ->

                    if !_.isUndefined(val)
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          name: 'required'

                  'type':        (val, objectKey, object, callback) ->

                    if val
                      callback null,
                        success: true
                    else
                      callback null,
                        success:   true
                        transform: [objectKey, 'type', 'full']
                      ###
                      callback null,
                        success: false
                        message:
                          type: 'required'
                      ###

                  'employeeUid': (val, objectKey, object, callback) ->

                    if !val
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
                            uid: val
                        ).success (resultEmployee) ->
                          callback null, resultEmployee


                    ], (error, results) ->

                      resultClient   = results[0]
                      resultEmployee = results[1]

                      if !resultEmployee
                        callback null,
                          success: false
                          message:
                            'employeeUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultEmployee.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'employeeUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultEmployee.uid] = resultEmployee
                      mapObj[resultClient.uid]   = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'clientUid', resultClient.uid]


                  'clientUid': (val, objectKey, object, callback) ->

                    #TODO: Verify legit client
                    callback null,
                      success: true
                    return


              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'templates', clientUid, template, objects, req, res, app, insertMethodCallback


            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->

                  insertChildRevisionAndGroupHelper createdUid, (uid) ->
                    callback null, uid

              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod req.body, (uid) ->

                if _.isString(uid) && _.isUndefined(uid.code)

                  insertChildRevisionAndGroupHelper uid, (uid) ->
                    config.apiSuccessPostResponse res, uid

                else
                  res.jsonAPIRespond uid


          when 'clientSuperAdmin', 'clientAdmin'
            insertMethod = (item, insertMethodCallback = false) ->
              apiVerifyObjectProperties this, template, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'name':        (val, objectKey, object, callback) ->

                    if !_.isUndefined(val)
                      callback null,
                        success: true
                    else
                      callback null,
                        success: false
                        message:
                          name: 'required'

                  'type':        (val, objectKey, object, callback) ->

                    if val
                      callback null,
                        success: true
                    else
                      val = 'full'
                      callback null,
                        success:   true
                        transform: [objectKey, 'type', 'full']
                      ###
                      callback null,
                        success: false
                        message:
                          type: 'required'
                      ###

                  'employeeUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      val = uid

                    where =
                      uid:       val
                      clientUid: clientUid

                    #check exists
                    employee.find(
                      where: where  #<-- make sure to limit to session clientUid
                    ).success (resultEmployee) ->

                      if resultEmployee
                        mapObj = {}
                        mapObj[resultEmployee.uid] = resultEmployee
                        callback null,
                          uidMapping: mapObj
                          success:    true
                          transform:  [objectKey, 'employeeUid', resultEmployee.uid]

                      else
                        callback null,
                          success: false
                          message:
                            employeeUid: 'unknown'

                  'clientUid': (val, objectKey, object, callback) ->

                    #For everyone besides superAdmins, they shouldn't be specifying clientUids
                    if !_.isUndefined val
                      callback null,
                        success: false
                        message:
                          clientUid: 'unknown'
                      return
                    else
                      client.find(
                        where:
                          uid: clientUid
                      ).success (resultClient) ->
                        #This should never fail, apiAuth should block
                        mapObj = {}
                        mapObj[resultClient.uid] = resultClient
                        callback null,
                          success: true
                          uidMapping: mapObj
                          transform: [objectKey, 'clientUid', clientUid] #<-- take from session

              }, (objects) ->
                #insertHelper.call(this, objects, res)
                insertHelper 'templates', clientUid, template, objects, req, res, app, insertMethodCallback


            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->

                  insertChildRevisionAndGroupHelper createdUid, (uid) ->
                    callback null, uid

              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod req.body, (uid) ->

                if _.isString(uid) && _.isUndefined(uid.code)

                  insertChildRevisionAndGroupHelper uid, (uid) ->
                    config.apiSuccessPostResponse res, uid

                else
                  res.jsonAPIRespond uid


          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]



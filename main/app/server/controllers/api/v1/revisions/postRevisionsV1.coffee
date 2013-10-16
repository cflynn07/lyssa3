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

  revision = ORM.model 'revision'
  template = ORM.model 'template'
  client   = ORM.model 'client'
  employee = ORM.model 'employee'

  app.post config.apiSubDir + '/v1/revisions', (req, res) ->
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
              apiVerifyObjectProperties this, revision, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'changeSummary': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          changeSummary: 'required'
                    else
                      callback null,
                        success: true

                  'scope': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          scope: 'required'
                    else
                      callback null,
                        success: true

                  'clientUid': (val, objectKey, object, callback) ->

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    callback null,
                      success:   true
                      transform: [objectKey, 'clientUid', testClientUid]

                    ###
                    if _.isUndefined val
                      callback null,
                        success: true
                        transform:  [objectKey, 'clientUid', clientUid]

                    else
                      client.find(
                        where:
                          uid: val
                      ).success (resultClient) ->

                        if resultClient
                          mapObj = {}
                          mapObj[resultClient.uid] = resultClient
                          callback null,
                            success:    true
                            uidMapping: mapObj
                            #transform:  [objectKey, 'clientUid', resultClient.uid]
                        else
                          callback null,
                            success: false
                            message:
                              clientUid: 'unknown'
                    ###

                  'templateUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          templateUid: 'required'
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
                        template.find(
                          where:
                            uid: val
                        ).success (resultTemplate) ->
                          callback null, resultTemplate


                    ], (error, results) ->

                      resultClient   = results[0]
                      resultTemplate = results[1]

                      if !resultTemplate
                        callback null,
                          success: false
                          message:
                            'templateUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultTemplate.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'templateUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultTemplate.uid] = resultTemplate
                      mapObj[resultClient.uid]   = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'clientUid', resultClient.uid]

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'revisions', clientUid, revision, objects, req, res, app, insertMethodCallback

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
              apiVerifyObjectProperties this, revision, item, req, res, insertMethodCallback, {
                requiredProperties:
                  'changeSummary': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          changeSummary: 'required'
                    else
                      callback null,
                        success: true

                  'scope': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          scope: 'required'
                    else
                      callback null,
                        success: true

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


                  'templateUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val
                      callback null,
                        success: false
                        message:
                          templateUid: 'required'
                      return

                    async.parallel [
                      (callback) ->
                        client.find(
                          where:
                            uid: clientUid
                        ).success (resultClient) ->
                          callback null, resultClient

                      (callback) ->
                        template.find(
                          where:
                            uid: val
                        ).success (resultTemplate) ->
                          callback null, resultTemplate


                    ], (error, results) ->

                      resultClient   = results[0]
                      resultTemplate = results[1]

                      if !resultTemplate
                        callback null,
                          success: false
                          message:
                            'templateUid': 'unknown'
                        return

                      if !resultClient
                        callback null,
                          success: false
                          'clientUid': 'unknown'
                        return

                      #IF we do find the employee, but it doesn't belong to the same client...
                      if resultTemplate.clientUid != resultClient.uid
                        callback null,
                          success: false
                          message:
                            'templateUid': 'unknown'
                        return

                      mapObj = {}
                      mapObj[resultTemplate.uid] = resultTemplate
                      mapObj[resultClient.uid]   = resultClient
                      callback null,
                        success: true
                        uidMapping: mapObj
                        transform: [objectKey, 'clientUid', resultClient.uid]

                  'employeeUid': (val, objectKey, object, callback) ->

                    if !_.isUndefined val
                        callback null,
                          success: false
                          message:
                            employeeUid: 'unknown'
                        return

                    async.parallel [
                      (callback) ->
                        client.find(
                          where:
                            uid: clientUid
                        ).success (resultClient) ->
                          callback null, resultClient

                      (callback) ->
                        employee.find(
                          where:
                            clientUid: clientUid
                            uid: employeeUid
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
                        transform: [objectKey, 'employeeUid', resultEmployee.uid]

              }, (objects) ->

                #insertHelper.call(this, objects, res)
                insertHelper 'revisions', clientUid, revision, objects, req, res, app, insertMethodCallback

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



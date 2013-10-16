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

  template = ORM.model 'template'
  employee = ORM.model 'employee'


  app.put config.apiSubDir + '/v1/templates', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType    = req.session.user.type
        clientUid   = req.session.user.clientUid
        employeeUid = req.session.user.uid

        switch userType
          when 'superAdmin'

            apiVerifyObjectProperties this, template, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    template.find(
                      where:
                        uid: val
                    ).success (resultTemplate) ->

                      if resultTemplate
                        mapObj = {}
                        mapObj[val] = resultTemplate
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
                'type': (val, objectKey, object, callback) ->
                  callback null,
                    success: true
                'deletedAt': (val, objectKey, object, callback) ->
                  if _.isUndefined(val)
                    callback null,
                      success: true
                    return

                  if (val != 'null') && (val is not null)
                    callback null,
                      success: false
                      message:
                        deletedAt: 'invalid'
                    return

                  callback null,
                    success: true
                    transform: [objectKey, 'deletedAt', null]

                'employeeUid': (val, objectKey, object, callback) ->

                  #find this template by checking uid, check to see if uid is set
                  #find clientUid of this template, verify that it matches this employeeUid
                  uid = object['uid']
                  if _.isUndefined uid
                    callback null,
                      success: false
                    return

                  if _.isUndefined val
                    val = employeeUid

                  callbacks = []

                  ((val) ->

                    callbacks.push (callback) ->
                      employee.find(
                        where:
                          uid: val
                      ).success (resultEmployee) ->
                        callback null, resultEmployee

                    callbacks.push (callback) ->
                      template.find(
                        where:
                          uid: uid
                      ).success (resultTemplate) ->
                        callback null, resultTemplate

                  )(val)

                  async.parallel callbacks, (err, results) ->

                    resultEmployee = results[0]
                    resultTemplate = results[1]

                    if !resultEmployee
                      callback null,
                        success: false
                        message:
                          'employeeUid': 'unknown'
                      return

                    if !resultTemplate
                      callback null,
                        success: false
                      return

                    if resultEmployee.clientUid != resultTemplate.clientUid
                      callback null,
                        success: false
                        message:
                          'employeeUid': 'unknown'
                      return

                    mapObj = {}
                    mapObj[resultEmployee.uid] = resultEmployee
                    callback null,
                      success: true
                      uidMapping: mapObj
                      transform: [objectKey, 'employeeUid', resultEmployee.uid]


            }, (objects) ->

              updateHelper template, objects, req, res, app


          when 'clientSuperAdmin', 'clientAdmin'

            apiVerifyObjectProperties this, template, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    template.find(
                      where:
                        uid: val
                        clientUid: clientUid #<-- restrict to session
                    ).success (resultTemplate) ->

                      if resultTemplate
                        mapObj = {}
                        mapObj[val] = resultTemplate
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
                'type': (val, objectKey, object, callback) ->
                  callback null,
                    success: true

                'deletedAt': (val, objectKey, object, callback) ->
                  if _.isUndefined(val)
                    callback null,
                      success: true
                    return

                  if (val != 'null') && (val is not null)
                    callback null,
                      success: false
                      message:
                        deletedAt: 'invalid'
                    return

                  callback null,
                    success: true

                'employeeUid': (val, objectKey, object, callback) ->

                  #find this template by checking uid, check to see if uid is set
                  #find clientUid of this template, verify that it matches this employeeUid
                  uid = object['uid']
                  if _.isUndefined uid
                    callback null,
                      success: false
                    return

                  #If unspecified
                  if _.isUndefined val
                    val = employeeUid

                  callbacks = []

                  ((val) ->

                    callbacks.push (callback) ->
                      employee.find(
                        where:
                          uid: val
                          clientUid: clientUid
                      ).success (resultEmployee) ->
                        callback null, resultEmployee

                    callbacks.push (callback) ->
                      template.find(
                        where:
                          uid: uid
                          clientUid: clientUid
                      ).success (resultTemplate) ->
                        callback null, resultTemplate

                  )(val)

                  async.parallel callbacks, (err, results) ->

                    resultEmployee = results[0]
                    resultTemplate = results[1]

                    if !resultEmployee
                      callback null,
                        success: false
                        message:
                          employeeUid: 'unknown'
                      return

                    if !resultTemplate
                      callback null,
                        success: false
                      return

                    if resultEmployee.clientUid != resultTemplate.clientUid
                      callback null,
                        success: false
                        message:
                          employeeUid: 'unknown'
                      return

                    mapObj = {}
                    mapObj[resultEmployee.uid] = resultEmployee
                    callback null,
                      success: true
                      uidMapping: mapObj
                      transform: [objectKey, 'employeeUid', resultEmployee.uid]

            }, (objects) ->

              updateHelper template, objects, req, res, app


          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]



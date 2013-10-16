_                         = require 'underscore'
async                     = require 'async'
bcrypt                    = require 'bcrypt'
uuid                      = require 'node-uuid'
config                    = require GLOBAL.appRoot + 'config/config'
apiVerifyObjectProperties = require GLOBAL.appRoot + 'components/apiVerifyObjectProperties'
apiAuth                   = require GLOBAL.appRoot + 'components/apiAuth'
ORM                       = require GLOBAL.appRoot + 'components/oRM'
updateHelper              = require GLOBAL.appRoot + 'components/updateHelper'
sequelize                 = ORM.setup()

module.exports = (app) ->

  client   = ORM.model 'client'
  employee = ORM.model 'employee'

  app.put config.apiSubDir + '/v1/employees', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid

        switch userType
          when 'superAdmin'

            apiVerifyObjectProperties this, employee, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    employee.find(
                      where:
                        uid: val
                    ).success (resultEmployee) ->

                      if resultEmployee
                        mapObj = {}
                        mapObj[val] = resultEmployee
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'identifier': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: true
                    return

                  if _.isUndefined object['uid']
                    callback null,
                      success: false
                    return

                  employee.find(
                    where:
                      uid: object['uid']
                  ).success (resultEmployee) ->

                    employee.find(
                      where:
                        identifier: val
                        clientUid: resultEmployee.clientUid
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee && resultEmployee.uid != object['uid']
                        callback null,
                          success: false
                          message:
                            identifier: 'duplicate'
                      else
                        callback null,
                          success: true

                'firstName': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'lastName': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'email': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'phone': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'username': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: true
                    return

                  if _.isUndefined object['uid']
                    callback null,
                      success: false
                    return

                  employee.find(
                    where:
                      uid: object['uid']
                  ).success (resultEmployee) ->

                    employee.find(
                      where:
                        username: val
                        clientUid: resultEmployee.clientUid
                    ).success (resultEmployee) ->

                      #Cant be duplicates
                      if resultEmployee && resultEmployee.uid != object['uid']
                        callback null,
                          success: false
                          message:
                            username: 'duplicate'
                      else
                        callback null,
                          success: true

                'password': (val, objectKey, object, callback) ->

                  if _.isUndefined(val) || val.length > 100
                    callback null,
                      success: false
                    return

                  #Convert string to hash
                  bcrypt.genSalt 10, (err, salt) ->
                    bcrypt.hash val, salt, (err, hash) ->
                      callback null,
                        success:   false
                        transform: [object, 'password', hash]

                'type': (val, objectKey, object, callback) ->

                  callback null,
                    success: false

            }, (objects) ->
              updateHelper employee, objects, req, res, app


          when 'clientSuperAdmin'

            #CSA Can make other CSA
            apiVerifyObjectProperties this, employee, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  console.log 'val'
                  console.log val

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    employee.find(
                      where:
                        uid: val
                    ).success (resultEmployee) ->

                      if resultEmployee
                        mapObj = {}
                        mapObj[val] = resultEmployee
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'identifier': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: true
                    return

                  if _.isUndefined object['uid']
                    callback null,
                      success: false
                    return

                  employee.find(
                    where:
                      clientUid:  clientUid
                      identifier: val
                  ).success (resultEmployee) ->

                    #Cant be duplicates
                    if resultEmployee && resultEmployee.uid != object['uid']
                      callback null,
                        success: false
                        message:
                          identifier: 'duplicate'
                    else
                      callback null,
                        success: true

                'firstName': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'lastName': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'email': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'phone': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'username': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: true
                    return

                  if _.isUndefined object['uid']
                    callback null,
                      success: false
                    return

                  employee.find(
                    where:
                      clientUid: clientUid
                      username:  val
                  ).success (resultEmployee) ->

                    #Cant be duplicates
                    if resultEmployee && resultEmployee.uid != object['uid']
                      callback null,
                        success: false
                        message:
                          username: 'duplicate'
                    else
                      callback null,
                        success: true

                'password': (val, objectKey, object, callback) ->

                  if _.isUndefined(val) || val.length > 100
                    callback null,
                      success: false
                    return

                  #Convert string to hash
                  bcrypt.genSalt 10, (err, salt) ->
                    bcrypt.hash val, salt, (err, hash) ->
                      callback null,
                        success:   false
                        transform: [object, 'password', hash]

                'type': (val, objectKey, object, callback) ->

                  if val == 'superAdmin'
                    callback null,
                      success: false
                      message:
                        type: 'invalid'
                    return

                  callback null,
                    success: false

            }, (objects) ->
              updateHelper employee, objects, req, res, app


          when 'clientAdmin'

            #CSA Can make other CSA
            apiVerifyObjectProperties this, employee, req.body, req, res, false, {
              requiredProperties:
                'uid': (val, objectKey, object, callback) ->

                  if _.isUndefined val
                    callback null,
                      success: false
                      message:
                        uid: 'required'
                  else

                    employee.find(
                      where:
                        uid: val
                    ).success (resultEmployee) ->

                      if resultEmployee
                        mapObj = {}
                        mapObj[val] = resultEmployee
                        callback null,
                          success: true
                          uidMapping: mapObj
                      else
                        callback null,
                          success: false
                          message:
                            uid: 'unknown'

                'identifier': (val, objectKey, object, callback) ->

                  if _.isUndefined username
                    callback null,
                      success: true
                    return

                  if _.isUndefined object['uid']
                    callback null,
                      success: false
                    return

                  employee.find(
                    where:
                      clientUid:  clientUid
                      identifier: val
                  ).success (resultEmployee) ->

                    #Cant be duplicates
                    if resultEmployee && resultEmployee.uid != object['uid']
                      callback null,
                        success: false
                        message:
                          identifier: 'duplicate'
                    else
                      callback null,
                        success: true

                'firstName': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'lastName': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'email': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'phone': (val, objectKey, object, callback) ->

                  callback null,
                    success: true

                'username': (val, objectKey, object, callback) ->

                  if _.isUndefined username
                    callback null,
                      success: true
                    return

                  if _.isUndefined object['uid']
                    callback null,
                      success: false
                    return

                  employee.find(
                    where:
                      clientUid: clientUid
                      username:  val
                  ).success (resultEmployee) ->

                    #Cant be duplicates
                    if resultEmployee && resultEmployee.uid != object['uid']
                      callback null,
                        success: false
                        message:
                          username: 'duplicate'
                    else
                      callback null,
                        success: true

                'password': (val, objectKey, object, callback) ->

                  if _.isUndefined(val) || val.length > 100
                    callback null,
                      success: false
                    return

                  #Convert string to hash
                  bcrypt.genSalt 10, (err, salt) ->
                    bcrypt.hash val, salt, (err, hash) ->
                      callback null,
                        success:   false
                        transform: [object, 'password', hash]

                'type': (val, objectKey, object, callback) ->

                  if val == 'superAdmin' or val == 'clientSuperAdmin'
                    callback null,
                      success: false
                      message:
                        type: 'invalid'
                    return

                  callback null,
                    success: true

            }, (objects) ->
              updateHelper employee, objects, req, res, app

          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]

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

module.exports = (app) ->

  employee = ORM.model 'employee'
  client   = ORM.model 'client'

  bulkObjectsIndex = 0

  app.post config.apiSubDir + '/v1/employees', (req, res) ->
    async.series [
      (callback) ->
        apiAuth req, res, callback
      (callback) ->

        userType  = req.session.user.type
        clientUid = req.session.user.clientUid

        switch userType
          when 'superAdmin'

            insertMethod = (item, insertMethodCallback = false) ->

              apiVerifyObjectProperties this, employee, item, req, res, insertMethodCallback, {
                requiredProperties:

                  'identifier': (val, objectKey, object, callback) ->

                    callback null,
                      success: true
                    return

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    employee.find(
                      where:
                        clientUid:  testClientUid
                        identifier: val
                    ).success (resultEmployee) ->

                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            identifier: 'duplicate'
                      else
                        callback null,
                          success: true

                  'firstName': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          firstName: 'required'
                      return

                    callback null,
                      success: true

                  'lastName': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          lastName: 'required'
                      return

                    callback null,
                      success: true

                  'email': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          email: 'required'
                      return

                    #Verify no duplicates
                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid
                    employee.find(
                      where:
                        clientUid: testClientUid
                        email: val
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            email: 'duplicate'
                      else
                        callback null,
                          success: true


                  'phone': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          phone: 'required'
                      return

                    #Verify no duplicates
                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid
                    employee.find(
                      where:
                        clientUid: testClientUid
                        phone: val
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            phone: 'duplicate'
                      else
                        callback null,
                          success: true

                  'username': (val, objectKey, object, callback) ->

                    callback null,
                      success: true
                    return

                    testClientUid = if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid

                    employee.find(
                      where:
                        clientUid: testClientUid
                        username:  val
                    ).success (resultEmployee) ->

                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            username: 'duplicate'
                      else
                        callback null,
                          success: true

                  'password': (val, objectKey, object, callback) ->


                    callback null,
                      success: true
                    return

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

                    if _.isUndefined val
                      object[objectKey] = 'clientDelegate'

                    callback null,
                      success: false

                  'clientUid': (val, objectKey, object, callback) ->

                    if _.isUndefined val

                      client.find(
                        where:
                          uid: clientUid
                      ).success (resultClient) ->

                        if resultClient
                          mapObj = {}
                          mapObj[resultClient.uid]   = resultClient
                          callback null,
                            success: true
                            uidMapping: mapObj
                            transform: [objectKey, 'clientUid', resultClient.uid]
                        else
                          callback null,
                            success: false
                            message:
                              clientUid: 'unknown'

                    else

                      client.find(
                        where:
                          uid: val
                      ).success (resultClient) ->

                        if resultClient
                          mapObj = {}
                          mapObj[resultClient.uid]   = resultClient
                          callback null,
                            success: true
                            uidMapping: mapObj
                            transform: [objectKey, 'clientUid', resultClient.uid]
                        else
                          callback null,
                            success: false
                            message:
                              clientUid: 'unknown'


              }, (objects) ->
                #insertHelper objects, res
                insertHelper 'employees', clientUid, employee, objects, req, res, app, insertMethodCallback



            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->

                  callback null, createdUid

              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod(req.body)















          when 'clientSuperAdmin'

            insertMethod = (item, insertMethodCallback = false) ->
              #CSA Can make other CSA

              apiVerifyObjectProperties this, employee, item, req, res, insertMethodCallback, {
                requiredProperties:

                  'identifier': (val, objectKey, object, callback) ->

                    callback null,
                      success: true
                    return


                  'firstName': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          firstName: 'required'
                      return

                    callback null,
                      success: true

                  'lastName': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          lastName: 'required'
                      return

                    callback null,
                      success: true

                  'email': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          email: 'required'
                      return

                    if _.isUndefined(object['phone'])
                      callback null,
                        success: true
                      return

                    sql = ORM.SEQ.Utils.format [
                      'SELECT * FROM employees WHERE email = ? or phone = ? LIMIT 1'
                      val
                      object['phone']
                    ]

                    console.log sql

                    #Check both email & phone
                    sequelize.query(sql).success (resultEmployee) ->

                      if !resultEmployee || (resultEmployee.length is 0)
                        callback null,
                          success: true
                        return

                      errorMsg = {}

                      if resultEmployee.phone == object['phone']
                        errorMsg.phone = 'duplicate'

                      if resultEmployee.email == val
                        errorMsg.email = 'duplicate'

                      callback null,
                        success: false
                        message: errorMsg

                    ###
                    #Verify no duplicates
                    testClientUid = clientUid # if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid
                    employee.find(
                      where:
                        clientUid: testClientUid
                        email: val
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            email: 'duplicate'
                      else
                        callback null,
                          success: true
                    ###

                  'phone': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          phone: 'required'
                      return

                    callback null,
                      success: true

                    ###
                    #Verify no duplicates
                    testClientUid = clientUid # if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid
                    employee.find(
                      where:
                        clientUid: testClientUid
                        phone: val
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            phone: 'duplicate'
                      else
                        callback null,
                          success: true
                    ###


                  'username': (val, objectKey, object, callback) ->


                    callback null,
                      success: true


                  'password': (val, objectKey, object, callback) ->


                    callback null,
                      success: true
                    return


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

                    if _.isUndefined val
                      object['type'] = 'clientDelegate'
                      callback null,
                        success: true
                      #  transform: [object, 'type', 'clientDelegate']
                      return

                    callback null,
                      success: false

                  'clientUid': (val, objectKey, object, callback) ->

                    if !_.isUndefined(val)
                      callback null,
                        success: false
                        message:
                          clientUid: 'unknown'

                    client.find(
                      where:
                        uid: clientUid
                    ).success (resultClient) ->

                      if resultClient
                        mapObj = {}
                        mapObj[resultClient.uid]   = resultClient
                        callback null,
                          success: true
                          uidMapping: mapObj
                          transform: [objectKey, 'clientUid', resultClient.uid]
                      else
                        callback null,
                          success: false
                          message:
                            clientUid: 'unknown'


              }, (objects) ->
                console.log 'finish'
                console.log objects
                #insertHelper objects, res

                insertHelper 'employees', clientUid, employee, objects, req, res, app, insertMethodCallback


            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  console.log 'insertMethodCallback'
                  console.log arguments
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results

            else

              insertMethod req.body, (uid) ->

                if _.isString(uid) && _.isUndefined(uid.code)
                  config.apiSuccessPostResponse res, uid
                  activityInsert {
                    type:        'createEmployee'
                    employeeUid: uid
                    clientUid:   clientUid
                  }, app, req
                else
                  res.jsonAPIRespond uid





          when 'clientAdmin'

            insertMethod = (item, insertMethodCallback = false) ->
              #CSA Can make other CSA
              apiVerifyObjectProperties this, employee, item, req, res, insertMethodCallback, {
                requiredProperties:

                  'identifier': (val, objectKey, object, callback) ->

                    callback null,
                      success: true
                    return


                  'firstName': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          firstName: 'required'
                      return

                    callback null,
                      success: true

                  'lastName': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          lastName: 'required'
                      return

                    callback null,
                      success: true

                  'email': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          email: 'required'
                      return

                    if _.isUndefined(object['phone'])
                      callback null,
                        success: true
                      return

                    sql = ORM.SEQ.Utils.format [
                      'SELECT * FROM employees WHERE email = ? or phone = ? LIMIT 1'
                      val
                      object['phone']
                    ]

                    console.log sql

                    #Check both email & phone
                    sequelize.query(sql).success (resultEmployee) ->

                      if !resultEmployee || (resultEmployee.length is 0)
                        callback null,
                          success: true
                        return

                      errorMsg = {}

                      if resultEmployee.phone == object['phone']
                        errorMsg.phone = 'duplicate'

                      if resultEmployee.email == val
                        errorMsg.email = 'duplicate'

                      callback null,
                        success: false
                        message: errorMsg

                    ###
                    #Verify no duplicates
                    testClientUid = clientUid # if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid
                    employee.find(
                      where:
                        clientUid: testClientUid
                        email: val
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            email: 'duplicate'
                      else
                        callback null,
                          success: true
                    ###

                  'phone': (val, objectKey, object, callback) ->

                    if _.isUndefined(val) || val == ''
                      callback null,
                        success: false
                        message:
                          phone: 'required'
                      return

                    callback null,
                      success: true

                    ###
                    #Verify no duplicates
                    testClientUid = clientUid # if (!_.isUndefined object['clientUid']) then object['clientUid'] else clientUid
                    employee.find(
                      where:
                        clientUid: testClientUid
                        phone: val
                    ).success (resultEmployee) ->
                      #Cant be duplicates
                      if resultEmployee
                        callback null,
                          success: false
                          message:
                            phone: 'duplicate'
                      else
                        callback null,
                          success: true
                    ###


                  'username': (val, objectKey, object, callback) ->


                    callback null,
                      success: true


                  'password': (val, objectKey, object, callback) ->


                    callback null,
                      success: true
                    return


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

                    if val == 'superAdmin' || val == 'clientSuperAdmin'
                      callback null,
                        success: false
                        message:
                          type: 'invalid'
                      return

                    if _.isUndefined val
                      object['type'] = 'clientDelegate'
                      callback null,
                        success: true
                      #  transform: [object, 'type', 'clientDelegate']
                      return

                    callback null,
                      success: false

                  'clientUid': (val, objectKey, object, callback) ->

                    if !_.isUndefined(val)
                      callback null,
                        success: false
                        message:
                          clientUid: 'unknown'

                    client.find(
                      where:
                        uid: clientUid
                    ).success (resultClient) ->

                      if resultClient
                        mapObj = {}
                        mapObj[resultClient.uid]   = resultClient
                        callback null,
                          success: true
                          uidMapping: mapObj
                          transform: [objectKey, 'clientUid', resultClient.uid]
                      else
                        callback null,
                          success: false
                          message:
                            clientUid: 'unknown'

              }, (objects) ->
                #insertHelper objects, res
                insertHelper 'employees', clientUid, employee, objects, req, res, app, insertMethodCallback


            if _.isArray req.body
              async.mapSeries req.body, (item, callback) ->
                insertMethod item, (createdUid) ->
                  callback null, createdUid
              , (err, results) ->
                config.apiSuccessPostResponse res, results
            else
              insertMethod req.body, () ->

                if _.isString(uid) && _.isUndefined(uid.code)
                  config.apiSuccessPostResponse res, uid
                  activityInsert {
                    type:        'createEmployee'
                    employeeUid: uid
                    clientUid:   clientUid
                  }, app, req
                else
                  res.jsonAPIRespond uid


          when 'clientDelegate', 'clientAuditor'
            res.jsonAPIRespond config.errorResponse(401)

    ]

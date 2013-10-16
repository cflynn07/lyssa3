_ = require 'underscore'

config =
  resourceModelUnknownFieldsExceptions: {}
  isValidUUID: (uuid) ->
    rgx = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/
    return rgx.test(uuid)
  apiSubDir: '/api'
  env:       (if GLOBAL.app? and GLOBAL.app.settings? and GLOBAL.app.settings.env then GLOBAL.app.settings.env else 'development')
  authCategories: [
    'superAdmin'
    'clientSuperAdmin'
    'clientAdmin'
    'clientDelegate'
    'clientAuditor'
  ]
  apiResponseErrors:
    'nestedTooDeep':
      code: 400
      message: 'extend can not nest resources deeper than two levels'
    'invalidExpandJSON':
      code: 400
      message: 'invalid expand JSON parameter'
    'unknownExpandResource':
      code: 400
      message: 'unknown expand resource'
    'circularExpand':
      code: 400
      message: ''
    'unknownRootResourceId':
      code: 404
      message: 'unknown resource uid specified'
    'invalidFilterQuery':
      code: 400
      message: 'invalid filter query parameter'
    'invalidOrderQuery':
      code: 400
      message: 'invalid order query parameter'
    'generalInvalid':
      code: 400
      message: 'invalid request'
  defaultCode: 200
  apiResponseCodes:
    #Non-errors
    200: 'OK'
    201: 'Created'
    202: 'Accepted'
    #errors
    301: 'Moved Permanently'
    400: 'Bad Request'
    401: 'Unauthorized'
    402: 'Forbidden'
    404: 'Not Found'
  response: (code = 200) ->
    if [200, 201, 202].indexOf(code) is -1
      throw new Error 'Invalid API response'
      return
    code: code
    message: @apiResponseCodes[code]
  errorResponse: (code = 401) ->
    if [301, 400, 401, 402, 404].indexOf(code) is -1
      throw new Error 'Invalid API error response'
      return

    code: code
    error: @apiResponseCodes[code]
  apiErrorResponse: (apiResponseErrorName) ->
    apiResponseErrorsObject = @apiResponseErrors[apiResponseErrorName]

    if _.isUndefined apiResponseErrorsObject
      throw new Error 'Invalid API error response'
      return

    _.extend @errorResponse(apiResponseErrorsObject.code), message: apiResponseErrorsObject.message

  apiSuccessPostResponse: (res, responseUid) ->

    responseUids  = {}
    errorsIndexes = []

    if !_.isArray(responseUid)
      responseUids = {'0': responseUid}

    else if _.isArray(responseUid)
      for uid, key in responseUid
        if _.isObject uid
          errorsIndexes.push key
        responseUids[key] = uid

    finalResponseObj =
      code:    201
      message: @apiResponseCodes[201]
      uids:    responseUids

    if errorsIndexes.length > 0
      finalResponseObj.code    = 400
      finalResponseObj.message = @apiResponseCodes[400]
      finalResponseObj.errors  = errorsIndexes

    res.jsonAPIRespond finalResponseObj

  apiBroadcastPut: (resource, resultResource, app, req, res) ->

    if !_.isUndefined(req.query) && !_.isUndefined(req.query.silent)
      if req.query.silent == 'true'
        silent = true
      else
        silent = false
    else
      if req.requestType == 'http'
        silent = true
      else
        silent = false

    if !silent
      if !_.isUndefined(app.io) and _.isFunction(app.io.room)
        #console.log 'updateRP'
        #console.log resultResource.uid

        app.io.room(resultResource.uid).broadcast 'resourcePut',
          apiCollectionName: ''
          resourceName:      resource.name
          resource:          resultResource.values



#REDIS parameters
if GLOBAL.env and GLOBAL.env.DOTCLOUD_DATA_REDIS_HOST
  config.redis =
    prefix: 'voxtracker:'
    host:   GLOBAL.env.DOTCLOUD_DATA_REDIS_HOST
    port:   GLOBAL.env.DOTCLOUD_DATA_REDIS_PORT
    pass:   GLOBAL.env.DOTCLOUD_DATA_REDIS_PASSWORD
else
  config.redis =
    prefix: ''
    host:   'localhost'
    port:   6379
    pass:   ''

#MySQL parameters
if process.env.CIRCLECI
  #CircleCI CI
  config.mysql =
    host: 'localhost'
    user: ''
    pass: ''
    port: ''
    db:   'circle_test'
else if GLOBAL.env and GLOBAL.env.DOTCLOUD_DB_MYSQL_LOGIN
  #dotCloud
  config.mysql =
    host: GLOBAL.env.DOTCLOUD_DB_MYSQL_HOST
    user: GLOBAL.env.DOTCLOUD_DB_MYSQL_LOGIN
    pass: GLOBAL.env.DOTCLOUD_DB_MYSQL_PASSWORD
    port: GLOBAL.env.DOTCLOUD_DB_MYSQL_PORT
    db:   'production'
else
  #local development
  config.mysql =
    host: '127.0.0.1'
    user: 'root'
    pass: 'password'
    port: 3306
    db:   'development'

module.exports = config


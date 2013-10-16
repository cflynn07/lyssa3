_       = require 'underscore'
config  = require GLOBAL.appRoot + 'config/config'

module.exports = (req, res, callback) ->

  if req.requestType is 'http'

    #TEMP FOR debugging
    #if (req.query and req.session)
    #  _.extend req.session.user, req.query

    ## Token or session based authentication?
    if !req.session.user?
      res.jsonAPIRespond config.errorResponse(401)
    else if config.authCategories.indexOf(req.session.user.type) is -1
      res.jsonAPIRespond config.errorResponse(401)
    else
      #applyAuthBadge(req)
      callback()


  else if req.requestType is 'socketio'

    #TEMP FOR debugging
    #if (req.query and req.session)
    #  _.extend req.session.user, req.query

    #req.session = {}
    #req.session.user =
    #  type: 'superAdmin'

    ## Session based authentication
    if !req.session.user?
      res.jsonAPIRespond config.errorResponse(401)
    else if config.authCategories.indexOf(req.session.user.type) is -1
      res.jsonAPIRespond config.errorResponse(401)
    else
      #applyAuthBadge(req)
      callback()

  else
    throw new Error()# 'requestType not set'

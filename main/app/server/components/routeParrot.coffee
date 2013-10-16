_       = require 'underscore'
config  = require GLOBAL.appRoot + 'config/config'
#apiAuth = require config.appRoot + 'server/components/apiAuth'

module.exports.http = (req, res, next) ->


  #Modify if this is an API HTTP request
  if req.url.indexOf(config.apiSubDir) is 0

    if req.query and req.query.expand
      req.apiExpand = req.query.expand

    req.requestType    = 'http'
    res.jsonAPIRespond = (json) ->
      if !json.code?
        json.code = config.defaultCode
      res.json json.code, json

  next()


module.exports.socketio = (req, res, callback) ->

  #Tweak the REQ object so that the app.router will treat it as
  #a regular HTTP request
  httpEmulatedRequest =
    requestType: 'socketio'
    method:   if !_.isUndefined(req.data.method) then req.data.method else 'get'
    url:      config.apiSubDir + (if !_.isUndefined(req.data.url) then req.data.url else '/')
    headers:  []
    query:    if !_.isUndefined(req.data.query) then req.data.query else {}
    body:     if !_.isUndefined(req.data.data)  then req.data.data  else {}
  _.extend req, httpEmulatedRequest

  if !_.isUndefined(req.query) and !_.isUndefined(req.query.expand)
    req.apiExpand = req.query.expand

  res.jsonAPIRespond = (json) ->
    if !json.code?
      json.code = config.defaultCode
    req.io.respond json

  callback(req, res)

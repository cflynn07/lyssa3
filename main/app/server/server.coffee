#For including modules with absolute file paths
GLOBAL.appRoot = __dirname + '/'

# change

fs      = require 'fs'
express = require 'express.io'
path    = require 'path'

#If we didn't get to server.js from bootstrap.js
if !GLOBAL.assetHash
  GLOBAL.assetHash = 'client'

require(GLOBAL.appRoot + 'config/envGlobals')(GLOBAL)
require(GLOBAL.appRoot + 'components/oRM').setup()

config  = require GLOBAL.appRoot + 'config/config'

#redis clients
pub        = require(GLOBAL.appRoot + 'components/redis').createClient()
sub        = require(GLOBAL.appRoot + 'components/redis').createClient()
store      = require(GLOBAL.appRoot + 'components/redis').createClient()
redisStore = require(GLOBAL.appRoot + 'components/redis').createStore()
app        = express().http().io()

#Make express.io instance available globally
GLOBAL.app = app

app.io.set 'store',
  new express.io.RedisStore
    redis:       require 'redis'
    redisPub:    pub
    redisSub:    sub
    redisClient: store


#Socket.io configuration
app.io.set 'log level', 3
app.io.set 'transports', [
# 'websocket'
# 'flashsocket'
  'htmlfile'
  'xhr-polling'
  'jsonp-polling'
]


app.configure () ->

  app.use express.compress()
  app.disable 'x-powered-by'
  app.set 'port', process.env.PORT || 8080
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'ejs'
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session
    secret: 'c9d7732c0de118325e6de4582b37a4e9'
    store:  redisStore
    cookie:
      maxAge: 31536000000 # 1 day

  ###
    Route parrot middleware
    match api requests from socket.io & http to same handlers by modifying
    req & res objects
  ###
  app.use require(GLOBAL.appRoot + 'components/routeParrot').http
  app.use app.router


  app.configure 'production', () ->
    maxAge = 31536000000
    app.use express.static path.join(__dirname, '../client'), { maxAge: maxAge }

  app.configure 'development', () ->
    maxAge = 0 #Disable caching in development
    app.use express.static path.join(__dirname, '../client'), { maxAge: maxAge }
    app.use express.errorHandler()


#Authentication module
#require(GLOBAL.appRoot + 'controllers/authenticate')(app)

#API Requests
app.io.route 'apiRequest', (req) ->
  require(GLOBAL.appRoot + 'components/routeParrot').socketio req,
    {},
    (req, res) ->
      app.router req, res, () ->
        req.io.respond config.errorResponse(404)


#Mount all controllers (API & Regular)
require(GLOBAL.appRoot + 'components/controllers')(app)




###
test = require('./config/redis').createClient()
setInterval () ->
  test.publish 'eventsUpdated', 'test message'
, 1000
###



app.listen app.get 'port'
console.log 'server listening on port: ' + app.get 'port'

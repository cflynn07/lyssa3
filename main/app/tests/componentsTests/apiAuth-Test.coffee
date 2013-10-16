###
  Test authentication module
###

config  = require '../../server/config/config'
buster  = require 'buster'
_       = require 'underscore'
apiAuth = require config.appRoot + 'server/components/apiAuth'


buster.testCase 'Module components/apiAuth',

  setUp: (done) ->
    done()
  tearDown: (done) ->
    done()

  'Blocks unauthenticated HTTP request': ->

    request =
      requestType: 'http'
      session: {}
    response =
      jsonAPIRespond: this.spy()
    callback = this.spy()

    apiAuth(request, response, callback)

    buster.refute.called callback
    buster.assert.calledOnceWith response.jsonAPIRespond,
      error: 'Unauthorized'
      code: 401

  'Blocks unauthenticated socketio request': ->

    request =
      requestType: 'socketio'
      session: {}
    response =
      jsonAPIRespond: this.spy()
    callback = this.spy()

    apiAuth(request, response, callback)

    buster.refute.called callback
    buster.assert.calledOnceWith response.jsonAPIRespond,
      error: 'Unauthorized'
      code: 401


  'Allows authenticated "superAdmin" HTTP request': ->

    request =
      requestType: 'http'
      session:
        user:
          type: 'superAdmin'

    response =
      jsonAPIRespond: this.spy()
    callback = this.spy()

    apiAuth(request, response, callback)

    buster.assert.called callback
    buster.refute.called response.jsonAPIRespond

  'Allows authenticated "superAdmin" socketio request': ->

    request =
      requestType: 'socketio'
      session:
        user:
          type: 'superAdmin'

    response =
      jsonAPIRespond: this.spy()
    callback = this.spy()

    apiAuth(request, response, callback)

    buster.assert.called callback
    buster.refute.called response.jsonAPIRespond


  'Allows authenticated "clientSuperAdmin" socketio & HTTP request': () ->

    ((_this) ->
      request =
        requestType: 'socketio'
        session:
          user:
            type: 'clientSuperAdmin'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)

    ((_this) ->
      request =
        requestType: 'http'
        session:
          user:
            type: 'clientSuperAdmin'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)


  'Allows authenticated "clientAdmin" socketio & HTTP request': () ->

    ((_this) ->
      request =
        requestType: 'socketio'
        session:
          user:
            type: 'clientAdmin'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)

    ((_this) ->
      request =
        requestType: 'http'
        session:
          user:
            type: 'clientAdmin'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)



  'Allows authenticated "clientDelegate" socketio & HTTP request': () ->

    ((_this) ->
      request =
        requestType: 'socketio'
        session:
          user:
            type: 'clientDelegate'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)

    ((_this) ->
      request =
        requestType: 'http'
        session:
          user:
            type: 'clientDelegate'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)



  'Allows authenticated "clientAuditor" socketio & HTTP request': () ->

    ((_this) ->
      request =
        requestType: 'socketio'
        session:
          user:
            type: 'clientAuditor'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)

    ((_this) ->
      request =
        requestType: 'http'
        session:
          user:
            type: 'clientAuditor'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.assert.called callback
      buster.refute.called response.jsonAPIRespond
    )(this)

  'Does not allow unrecognized authCategory': () ->

    ((_this) ->
      request =
        requestType: 'socketio'
        session:
          user:
            type: 'foobar'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.refute.called callback
      buster.assert.calledOnceWith response.jsonAPIRespond,
        error: 'Unauthorized'
        code: 401
    )(this)

    ((_this) ->
      request =
        requestType: 'http'
        session:
          user:
            type: 'foobar'
      response =
        jsonAPIRespond: _this.spy()
      callback = _this.spy()

      apiAuth(request, response, callback)

      buster.refute.called callback
      buster.assert.calledOnceWith response.jsonAPIRespond,
        error: 'Unauthorized'
        code: 401
    )(this)


###
  Test the controllers component module to make
  sure proper routes are mounted
###

appDir  = '../../'
buster  = require 'buster'
express = require 'express.io'
app     = express().http().io()

#This recursively searches the controllers directory and mounts everything
require(appDir + 'server/components/controllers')(app)


buster.testCase 'Module components/controllers',

  setUp: (done) ->

    this.request =
      url: '/'
      method: 'GET'
      headers: []
    this.response =
      render: this.spy()
      end: this.spy()
      trim: this.spy()

    done()
  tearDown: (done) ->
    done()


  ###
  Testing 4 routes that should always be present after loading all routes
  ###
  'GET / - index present': () ->

    this.request.method = 'GET'
    next = this.spy()

    app.router this.request, this.response, next
    buster.refute.called next

  'POST / - index NOT present': () ->

    this.request.method = 'POST'
    next = this.spy()

    app.router this.request, this.response, next
    buster.assert.called next

  'PUT / - index NOT present': () ->

    this.request.method = 'PUT'
    next = this.spy()

    app.router this.request, this.response, next
    buster.assert.called next

  'DELETE / - index NOT present': () ->

    this.request.method = 'DELETE'
    next = this.spy()

    app.router this.request, this.response, next
    buster.assert.called next















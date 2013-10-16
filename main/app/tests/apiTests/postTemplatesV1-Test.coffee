buster        = require 'buster'
config        = require '../../server/config/config'
express       = require 'express.io'
postTemplates = require config.appRoot + 'server/controllers/api/v1/templates/postTemplatesV1'
ORM           = require config.appRoot + 'server/components/oRM'
async         = require 'async'
sequelize     = ORM.setup()
app           = express().http().io()
testConstants = require '../testConstants'

template      = ORM.model 'template'

#Bind the routes
postTemplates(app)

#helpers
verifyTemplateHelper = (session, requestBody, done, assertionsCallback) ->
  this.request.session         = session
  this.response.jsonAPIRespond = done (apiResponse) ->
    assertionsCallback apiResponse, next
  next = this.spy()
  app.router this.request, this.response, next



buster.testCase 'API V1 POST ' + config.apiSubDir + '/v1/templates',
  setUp: (done) ->

    this.request =
      url:          config.apiSubDir + '/v1/templates'
      method:       'POST'
      headers:      ['Content-Type':'application/json']
      requestType:  'http'
      body:         {}
      session:      {}
    this.response =
      render:         this.spy()
      end:            this.spy()
      trim:           this.spy()
      jsonAPIRespond: this.spy()


    done()
  tearDown: (done) ->
    done()

  '--> POST v1/templates exists & rejects unauthorized request': (done) ->


    #Is this even DRY???
    verifyTemplateHelper.call this,
      type:      'superAdmin'
      clientUid: testConstants.testDatabaseClients[0].uid
    ,
      name:        'test template 1'
      type:        'mini'
      employeeUid: testConstants.testDatabaseEmployees[0].uid
    ,
      done
    ,
      (apiResponse, next) ->
        buster.refute.called next
        buster.assert.same   JSON.stringify(apiResponse), JSON.stringify(config.errorResponse(401))



  '//--> POST v1/templates superAdmin succeeds with implied clientUid': (done) ->
    done()
  '//--> POST v1/templates superAdmin succeeds with specified clientUid': (done) ->
    done()
  '//--> POST v1/templates superAdmin succeeeds with multiple objects': (done) ->


  #success [superAdmin]
    #1. implied clientUid
    #2. specified clientUid
    #3. single object
    #4. array objects


  #success [clientSuperAdmin, clientAdmin]
    #1. single object
    #2. array objects
    #3. declines unknown employee
    #4. declines

  #success (declines) [clientDelegate, clientAuditor]
    #declines w/ 401

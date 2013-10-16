###
  Test API expansion module
###

config        = require '../../server/config/config'
testConstants = require '../testConstants'
buster        = require 'buster'
_             = require 'underscore'
apiExpand     = require config.appRoot + 'server/components/apiExpand'
ORM           = require config.appRoot + 'server/components/oRM'
sequelize     = ORM.setup()
async         = require 'async'


buster.testCase 'Module components/apiExpand',

  setUp: (done) ->

    this.request =
      url:          config.apiSubDir + '/v1/clients'
      method:       'GET'
      headers:      []
      requestType:  'http'
      session:      {}
    #  apiExpand:    {}
    this.response =
      render:         this.spy()
      end:            this.spy()
      trim:           this.spy()
      jsonAPIRespond: this.spy()

    done()
  tearDown: (done) ->
    done()

  # -------------------------------------------
  '--> Returns single resource without "expand" parameter': (done) ->

    _this = this

    testClientUid = testConstants.testDatabaseClients[2].uid #'05817084-bc15-4dee-90a1-2e0735a242e1'
    #testClientExpectedNumEmployees = testConstants.testDatabaseClients.length

    client = ORM.model 'client'
    resourceQueryParams =
      method: 'findAll'
      find:
        where:
          uid: testClientUid

    #this.request.apiExpand = [{
    #  resource: 'employees'
    #}]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code, 200
      #should always be object not array
      buster.assert.isObject apiResponse.response


    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams


  # -------------------------------------------
  '--> Returns multiple resources without "expand" parameter': (done) ->

    _this = this

    #testClientUid = ''
    #testClientExpectedNumEmployees = 2

    client = ORM.model 'client'
    resourceQueryParams =
      searchExpectsMultiple: true
      method: 'findAll'
      find: {}
      #  where:
      #    id: testClientId

    #this.request.apiExpand = [{
    #  resource: 'employees'
    #}]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code, 200
      buster.assert.isArray  apiResponse.response
      #make sure it didn't attach this...
      buster.refute.isArray  apiResponse.response.employees


    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams


  # -------------------------------------------
  '--> Returns a single resource wrapped in an array for requests to "collection" resources with only one result': (done) ->

    ###
    Always return array from GET API queries to base collection resources
    EX
      /api/v1/clients/
      /api/v1/employees/
    ###

    _this = this

    testClientUid = testConstants.testDatabaseClients[2].uid
    #testClientExpectedNumEmployees = 2

    client = ORM.model 'client'
    resourceQueryParams =
      searchExpectsMultiple: true
      method: 'findAll'
      find:
        where:
          uid: testClientUid

    #this.request.apiExpand = [{
    #  resource: 'employees'
    #}]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code, 200
      buster.assert.isArray  apiResponse.response
      buster.assert.same     apiResponse.response.length, 1
      #make sure it didn't attach this...
      buster.refute.isArray  apiResponse.response.employees


    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams


  # -------------------------------------------
  '--> Returns single resource with 1lvl deep expand parameter': (done) ->

    _this = this

    testClientId = 2
    #testClientExpectedNumEmployees = 2

    client = ORM.model 'client'
    resourceQueryParams =
      method: 'findAll'
      find:
        where:
          id: testClientId

    this.request.apiExpand = [{
      resource: 'employees'
    }]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code,    200
      buster.assert.isObject apiResponse.response

      #make sure it attached this
      buster.assert.isArray apiResponse.response.employees

    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams



  # -------------------------------------------
  '--> Returns multiple resource with 1lvl deep expand parameter': (done) ->

    _this = this

    #testClientExpectedNumEmployees = 3

    client = ORM.model 'client'
    resourceQueryParams =
      searchExpectsMultiple: true
      method: 'findAll'
      find: {}

    this.request.apiExpand = [{
      resource: 'employees'
    }]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code,    200

      #NOTE: API will only return array if response is plural, otherwise it will return an object
      #representing the single entity
      buster.assert.isArray  apiResponse.response

      #make sure it attached this
      for subResponse in apiResponse.response
        buster.assert.isArray subResponse.employees

    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams


  # -------------------------------------------
  '--> Returns single resource with 2lvl deep expand parameter': (done) ->

    _this = this

    testClientUid = testConstants.testDatabaseClients[1].uid

    client = ORM.model 'client'
    resourceQueryParams =
      method: 'findAll'
      find:
        where:
          uid: testClientUid

    this.request.apiExpand = [{
      resource: 'employees'
      expand: [{
        resource: 'templates'
      }]
    }]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code,    200
      buster.assert.isObject apiResponse.response

      #make sure it attached this
      buster.assert.isArray apiResponse.response.employees
      for employee in apiResponse.response.employees
        buster.assert.isArray employee.templates

    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams

  # -------------------------------------------
  '//--> Returns multiple resource with 2lvl deep expand parameter': (done) ->
    done()


  # -------------------------------------------
  '--> Returns error when attempting > 2lvl deep expand': (done) ->


    _this = this

    testClientUid = testConstants.testDatabaseClients[1].uid

    client = ORM.model 'client'
    resourceQueryParams =
      method: 'findAll'
      find:
        where:
          uid: testClientUid

    this.request.apiExpand = [{
      resource: 'templates'
      expand: [{
        resource: 'revisions'
        expand: [{
          resource: 'groups' #<-- LVL3, should fail
        }]
      }]
    },{
      resource: 'employees'
    }]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code,    config.apiResponseErrors['nestedTooDeep'].code
      buster.refute.isObject apiResponse.response
      buster.assert.same     apiResponse.message, config.apiResponseErrors['nestedTooDeep'].message

    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams

  # -------------------------------------------
  '//--> Returns error when attempting circular reference': (done) ->
    done()
  # -------------------------------------------
  '//--> Returns error when attempting duplicate reference': (done) ->
    done()




  '--> Invalid JSON "expand" parameter returns error': (done) ->
    _this = this

    testClientUid = testConstants.testDatabaseClients[1].uid

    client = ORM.model 'client'
    resourceQueryParams =
      method: 'findAll'
      find:
        where:
          uid: testClientUid

    #deliberate f'd up JSON
    this.request.apiExpand = "[{
      resfrrce:employees'
      expand: [{
        resdfsdfource: 'templates'
      }]
    }]"

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code,    config.apiResponseErrors['invalidExpandJSON'].code
      buster.refute.isObject apiResponse.response
      buster.assert.same     apiResponse.message, config.apiResponseErrors['invalidExpandJSON'].message

    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams


  '--> Malformed "expand" parameter returns error': (done) ->
    _this = this

    testClientUid = testConstants.testDatabaseClients[1].uid

    client = ORM.model 'client'
    resourceQueryParams =
      method: 'findAll'
      find:
        where:
          uid: testClientUid

    #deliberate f'd up JSON
    this.request.apiExpand = [{
      resource: 'employees'
      expand: {}  #<--Invalid
    }]

    _this.response.jsonAPIRespond = done (apiResponse) ->

      buster.assert.isObject apiResponse
      buster.assert.same     apiResponse.code,    config.apiResponseErrors['invalidExpandJSON'].code
      buster.refute.isObject apiResponse.response
      buster.assert.same     apiResponse.message, config.apiResponseErrors['invalidExpandJSON'].message


    #Run test
    apiExpand this.request, this.response, client, resourceQueryParams





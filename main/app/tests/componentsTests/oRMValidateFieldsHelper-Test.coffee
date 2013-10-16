config                = require '../../server/config/config'
testConstants         = require '../testConstants'
buster                = require 'buster'
_                     = require 'underscore'
ORM                   = require config.appRoot + 'server/components/oRM'
sequelize             = ORM.setup()
async                 = require 'async'


buster.testCase 'Module components/oRMValidateFieldsHelper',

  setUp: (done) ->
    done()
  tearDown: (done) ->
    done()

  # -------------------------------------------
  '//--> Returns code 400 & error message when required field is not present': (done) ->




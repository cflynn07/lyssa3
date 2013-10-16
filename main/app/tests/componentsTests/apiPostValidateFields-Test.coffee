config                = require '../../server/config/config'
ORM                   = require config.appRoot + 'server/components/oRM'
apiPostValidateFields = require config.appRoot + 'server/components/apiPostValidateFields'
testConstants         = require '../testConstants'
sequelize             = ORM.setup()
buster                = require 'buster'
async                 = require 'async'
_                     = require 'underscore'


buster.testCase 'Module components/apiPostValidateFields',

  setUp: (done) ->
    done()
  tearDown: (done) ->
    done()

  # -------------------------------------------
  '//--> Returns code 400 & error message when required field is not present': (done) ->




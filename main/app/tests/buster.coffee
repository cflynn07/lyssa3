
execSync = require 'exec-sync'
config   = require '../server/config/config'


if process.env.CIRCLECI
  output = execSync 'mysql -u ubuntu circle_test < ' + config.appRoot + 'tests/apiTests/lyssa.sql'
else
  mysql = '/usr/local/mysql/bin/mysql'
  output = execSync mysql + ' -u root lyssa < ' + config.appRoot + 'tests/apiTests/lyssa.sql'


config = module.exports
config['Tests'] =
  rootPath: "."
  environment: "node"
#These are not required for nodejs tests
#  sources: [
#    'lib/mylib.js'
#    'lib/**/*.js'
#  ]
  tests: [
   # './**/*-test.js'
   # 'integrationTests/**/*-test.js'
    '**/*Test.js'
  ]

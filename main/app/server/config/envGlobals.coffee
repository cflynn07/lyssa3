#Read dotCloud ENV file if exists
fs = require 'fs'

module.exports = (GLOBAL) ->
  try
    GLOBAL.env = JSON.parse fs.readFileSync '/home/dotcloud/environment.json', 'utf-8'
  catch error
    GLOBAL.env = false

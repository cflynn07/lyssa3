###
  Recursively search & attach route handlers in /server/controllers directory
###
controllersPath = GLOBAL.appRoot + 'controllers'
fs              = require 'fs'

module.exports = (app) ->

  searchDirectory = (dir) ->
    fs.readdirSync(dir).forEach (name) ->
      if name.indexOf('.coffee') > 0
        return

      stats = fs.lstatSync dir + '/' + name
      if stats.isDirectory()
        searchDirectory(dir + '/' + name)
      else
        controller = require dir + '/' + name
        controller(app)

  searchDirectory(controllersPath)

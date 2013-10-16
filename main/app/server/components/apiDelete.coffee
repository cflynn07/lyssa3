async  = require 'async'
_      = require 'underscore'
config = require GLOBAL.appRoot + 'config/config'

module.exports = (resource, conditions, res) ->

  resource.findAll(
    where: conditions
  ).success (resources) ->

    deletedItems = []

    async.map resources, (item, callback) ->

      if _.isNull item.deletedAt
        deletedItems.push item.uid

      item.destroy().success () ->

        if !_.isUndefined(app.io) and _.isFunction(app.io.room)
          #app.io.room(item.uid).broadcast 'resourcePut', JSON.parse(JSON.stringify(item))

          app.io.room(item.uid).broadcast 'resourcePut',
            apiCollectionName: ''
            resourceName:      resource.name
            resource:          JSON.parse(JSON.stringify(item))


        callback()

    , () ->

      res.jsonAPIRespond _.extend {code: 202, message: config.apiResponseCodes[202]}, deletedItems: deletedItems

Sequelize  = require 'sequelize'
fs         = require 'fs'
_          = require 'underscore'
config     = require GLOBAL.appRoot + 'config/config'
modelsPath = GLOBAL.appRoot + 'models'

exportObj =
  setup: () ->

    if @instance
      return @instance

    sequelizeDefaults =
      maxConcurrentQueries: 100
      pool:
        maxConnections: 5
        maxIdleTime:    30
      define:
        underscored: false
      syncOnAssociation: false
      paranoid: true
      logging:  false #console.log #<-- set to console.log for query debugging

    sequelizeDefaults = _.extend sequelizeDefaults, config.mysql
    sequelize         = new Sequelize config.mysql.db, 
      config.mysql.user, 
      config.mysql.pass, 
      sequelizeDefaults

    relationships = @relationships
    models        = @models

    #Hash of model objects to write to JSON file & share with client
    exportModels = {}
    fs.readdirSync(modelsPath).forEach (name) ->

      if name.indexOf('.coffee') > 0
        return

      object    = require modelsPath + '/' + name
      options   = object.options || {}
      modelName = name.replace(/\.js$/i, '')

      #console.log modelName

      #add uid to each model
      object.model = _.extend({uid:
        type: Sequelize.STRING
        validate:
          isUUID:  4
          notNull: true
          unique:  true
      }, object.model)

      models[modelName]       = sequelize.define modelName, object.model, options
      exportModels[modelName] =
        model: object.model

      if object.relations
        relationships[modelName]          = object.relations
        exportModels[modelName].relations = object.relations

    ###
    # Use the following line to export your ORM objects to the client side to share validation rules (useful)
    ###
    #Write to JSON
    fs.writeFileSync GLOBAL.appRoot + '../client/config/clientOrmShare.json', JSON.stringify(exportModels)

    for modelName, relations of @relationships
      for relObject in relations
        if !_.isObject relObject.options
          relObject.options = {}
        @models[modelName][relObject.relation](@models[relObject.model], relObject.options)

    @instance = sequelize
    return @instance

  instance:      null
  SEQ:           Sequelize
  models:        []
  relationships: {}
  model: (name) ->
    @models[name]

module.exports = exportObj

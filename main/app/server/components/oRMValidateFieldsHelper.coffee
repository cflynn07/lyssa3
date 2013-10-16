_      = require 'underscore'
async  = require 'async'
config = require GLOBAL.appRoot + 'config/config'

module.exports = (postObjects, resourceModel) ->

  #collect everything wrong with the object to send back to user
  objectValidationErrors = []


  ###
  console.log 'resourceModel.name'
  console.log resourceModel.name
  console.log 'resourceModel.rawAttributes'
  console.log resourceModel.rawAttributes
  ###


  for object, key in postObjects
    #Test some validations on resourceModel, namely ENUM types

    #console.log 'object'
    #console.log object


    for propertyName, propertyValue of object

      testAttribute = resourceModel.rawAttributes[propertyName]
      if !_.isUndefined testAttribute

        #console.log testAttribute.type
        #console.log testAttribute.values
        #console.log 'testAttribute.type'
        #console.log testAttribute.type

        if testAttribute.type and (testAttribute.type is 'ENUM')
          if testAttribute.values.indexOf(propertyValue) is -1
            #ERROR, non-allowed value
            errorObj = {}
            errorObj[propertyName] = 'invalid value'
            objectValidationErrors.push errorObj


        #Test some other validations
        if !_.isUndefined testAttribute.validate

          #alphanumeric
          if !_.isUndefined(testAttribute.validate.isAlphanumeric) and testAttribute.validate.isAlphanumeric
            if (propertyValue.length > 0) and !propertyValue.match(/^[ 0-9a-zA-Z]+$/)
              errorObj = {}
              errorObj[propertyName] = 'must be alphanumeric'
              objectValidationErrors.push errorObj

          #min/max length
          if !_.isUndefined(testAttribute.validate.len) and _.isArray(testAttribute.validate.len)
            if (propertyValue.length < testAttribute.validate.len[0]) || (propertyValue.length > testAttribute.validate.len[1])
              errorObj = {}
              errorObj[propertyName] = 'length must be between ' + testAttribute.validate.len[0] + ' and ' + testAttribute.validate.len[1]
              objectValidationErrors.push errorObj

          #integer
          if testAttribute.type and (testAttribute.type is 'INTEGER')
            if ! /^\d+$/.test(propertyValue + '')
              #ERROR, non-allowed value
              errorObj = {}
              errorObj[propertyName] = 'invalid value'
              objectValidationErrors.push errorObj


  return objectValidationErrors

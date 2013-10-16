_                          = require 'underscore'
uuid                       = require 'node-uuid'
async                      = require 'async'
config                     = require GLOBAL.appRoot + 'config/config'
oRMValidateFieldsHelper    = require GLOBAL.appRoot + 'components/oRMValidateFieldsHelper'
preventUnknownFieldsHelper = require GLOBAL.appRoot + 'components/preventUnknownFieldsHelper'

module.exports = (scope, resourceModel, testObjects, req, res, insertMethodCallback = false, requirements, finalMethod) ->

  ###
  First iterate over all the properties of all the objects and verify that all required fields are present
  Also build an array of callbacks to test each required field
  ###

  if _.isArray(testObjects) || !_.isObject(testObjects)
    resp = config.errorResponse(400)
    if insertMethodCallback
      insertMethodCallback resp
    else
      res.jsonAPIRespond resp
    return

  testObjects = [testObjects]

  unknownProperties = preventUnknownFieldsHelper(resourceModel, testObjects, requirements)
  if unknownProperties.length > 0
    resp = _.extend config.errorResponse(400), {messages: unknownProperties}
    if insertMethodCallback
      insertMethodCallback resp
    else
      res.jsonAPIRespond resp
    return

  #validates each object property against any validation specs in resourceModel
  objectValidationErrors = oRMValidateFieldsHelper testObjects, resourceModel
  if objectValidationErrors.length > 0
    resp = _.extend config.errorResponse(400), messages: objectValidationErrors
    if insertMethodCallback
      insertMethodCallback resp
    else
      res.jsonAPIRespond resp
    return


  async.series [
    (superCallback) ->

      propertyAsyncMethods = []
      for object, key in testObjects
        for propertyName, propertyValueCheckCallback of requirements.requiredProperties

          valueToTest = object[propertyName]

          ((valueToTest, propertyValueCheckCallback, scope, objectKey, object)->

            propertyAsyncMethods.push (callback) ->
              propertyValueCheckCallback.call scope, valueToTest, objectKey, object, callback

          )(valueToTest, propertyValueCheckCallback, scope, key, object)


      #Asynchronously execute callbacks, if all tests pass insert objects, otherwise return error
      uidMappings = {}
      errorMessages = []
      async.parallel propertyAsyncMethods, (err, results) ->


        #results will be array of results from each callback test
        for val in results
          if val.success is false

            if val.message
              errorMessages.push val.message

          else

            if _.isObject val.uidMapping
              for mappingUid, mappingORMResource of val.uidMapping
                uidMappings[mappingUid] = mappingORMResource
                #console.log mappingUid


          if _.isArray val.transform
            testObjects[val.transform[0]][val.transform[1]] = val.transform[2]



        if (objectValidationErrors.length > 0) or (errorMessages.length > 0)
          #  res.jsonAPIRespond _.extend config.errorResponse(400), messages: objectValidationErrors

          #\/ -- newer than ^
          #res.jsonAPIRespond _.extend config.errorResponse(400), messages: errorMessages.concat objectValidationErrors
          resp = _.extend config.errorResponse(400), messages: errorMessages.concat objectValidationErrors
          if insertMethodCallback
            insertMethodCallback resp
          else
            res.jsonAPIRespond resp

          superCallback(new Error 'object property test failed')
          return



        #attach id's for uids
        for object, key in testObjects

          #Give everyone their own brand new uid
          #testObjects[key]['uid'] = uuid.v4()
          #console.log uidMappings
          for objectPropKey, objectPropValue of object
            #console.log objectPropKey
            #console.log objectPropValue
            if _.isNull(objectPropValue) || _.isUndefined(objectPropValue)
              continue

            suffix = 'Uid'

            if objectPropKey.indexOf(suffix, objectPropKey.length - suffix.length) > -1
              #This property ends in Uid
              propertyAssocORM                        = uidMappings[objectPropValue]
              propertyPrefix                          = objectPropKey.substring(0, objectPropKey.indexOf('Uid'))
              testObjects[key][propertyPrefix + 'Id'] = propertyAssocORM.id


          #success
          superCallback(null, uidMappings)

    (superCallback) ->
      finalMethod testObjects

  ]



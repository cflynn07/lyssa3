define [
  'underscore'
  'uuid'
  'utils/utilSortHash'
  'text!config/clientOrmShare.json'
], (
  _
  uuid
  utilSortHash
  clientOrmShare
) ->

  clientOrmShare = JSON.parse clientOrmShare

  (Module) ->
    Module.factory 'apiRequest', ['socket', '$rootScope',
    (socket, $rootScope) ->

      resourcePool = {}
      $rootScope.resourcePool = resourcePool
      window.resourcePool     = $rootScope.resourcePool
      window.rootScope        = $rootScope

      #Cache of results in resourcePool based on query parameters
      resourcePoolResultCache = {}

      ###
      #  Helpers
      ###
      helperMeshResourceWithPool = (data) ->
        if !_.isUndefined(data['resource']) and !_.isUndefined(data['resource']['uid'])

          if !_.isUndefined resourcePool[data['resource']['uid']]
            _.extend resourcePool[data['resource']['uid']], data['resource']
          else
            resourcePool[data['resource']['uid']] = data['resource']

      helperValidateResource = (resourceName) ->
        if _.isUndefined clientOrmShare[resourceName]
          throw new Error resourceName + ' is unknown'
          return false
        return true

      helperGetCollectionName = (resourceName) ->
        apiCollectionName = resourceName + 's'
        #exception to pluralization rules
        if resourceName == 'dictionary'
          apiCollectionName = 'dictionaries'
        if resourceName == 'activity'
          apiCollectionName = 'activity'
        return apiCollectionName

      #To assist with caching API results by 4 params (offset, limit, filter, order)
      helperHashApiRequests = (resourceName, options) ->
        defaultOptions =
          offset: 0
          limit:  300 #API DEF
          filter: []
          order:  []
          uids:   []
        _.extend defaultOptions, options

        #Flatten arrays to aid in creating simple hash string
        #Must sort by propName
        filter = []
        filter = _.sortBy defaultOptions.filter, (arr) ->
          return arr[0] + arr[1] + [2]

        order = []
        order = _.sortBy defaultOptions.order, (arr) ->
          return arr[0] + arr[1]        

        uids = []
        uids = _.sortBy defaultOptions.uids, (uid) ->
          return uid

        hashString = resourceName + 
          defaultOptions.offset   +
          defaultOptions.limit    +
          JSON.stringify(filter)  +
          JSON.stringify(order)   + 
          uids.join(',')

        return hashString

      #Merges new values of objects pulled from server with cache-pool present on the client
      helperUpdateResourcePool = (resourcesArrayOrObject) ->

        mergeObjectWithRP = (object) ->
          if _.isString(object['uid'])
            if !_.isUndefined(resourcePool[object['uid']])
              _.extend resourcePool[object['uid']], object
            else
              resourcePool[object['uid']] = object

        if _.isArray(resourcesArrayOrObject) && !_.isString(resourcesArrayOrObject)
          for item in resourcesArrayOrObject
            helperUpdateResourcePool item

        else if _.isObject(resourcesArrayOrObject)
          mergeObjectWithRP resourcesArrayOrObject

          for property, value of resourcesArrayOrObject
            if (_.isArray(value) || _.isObject(value)) && !_.isString(value)
              helperUpdateResourcePool value


      socket.on 'resourcePut', (data) ->
        helperMeshResourceWithPool data
        $rootScope.$broadcast 'resourcePut', data

      socket.on 'resourcePost', (data) ->
        helperMeshResourceWithPool data
        $rootScope.$broadcast 'resourcePost', data


      ###
      # Response Object
      ###
      factory =
        get: (resourceName, uids = [], query = {}, callback = null) ->

          if !helperValidateResource resourceName
            return
          apiCollectionName = helperGetCollectionName resourceName

          hashString = helperHashApiRequests apiCollectionName,
            offset: if query.offset then query.offset else 0
            limit:  if query.limit  then query.limit  else 300
            filter: if query.filter then query.filter else []
            order:  if query.order  then query.order  else []
            uids:   uids

          if !_.isUndefined(resourcePoolResultCache[hashString])            
            callback resourcePoolResultCache[hashString].response, resourcePoolResultCache[hashString].responseRaw, true

          socket.apiRequest 'GET',
            '/' + apiCollectionName + '/' + uids.join(','),
            query, #query
            {},    #data
            (response) ->
              responseRaw = JSON.stringify(response)

              if !_.isObject(response) || _.isUndefined(response.code) || response.code != 200
                callback response, responseRaw, false
                return

              #Always return results in array format if no uids specified
              if (uids.length is 0) and !_.isArray(response.response.data) && _.isObject(response.response.data)
                response.response.data = [response.response.data]

              #Replaces each object in data with object from resourcePool
              helperUpdateResourcePool response.response.data

              resourcePoolResultCache[hashString] =
                response: response
                responseRaw: responseRaw

              callback response, responseRaw, false

        post: (resourceName, objects, query, callback) ->
          if !helperValidateResource resourceName
            return
          apiCollectionName = helperGetCollectionName resourceName

          socket.apiRequest 'POST',
            '/' + apiCollectionName,
            query,   #query
            objects, #data
            (response) ->
              callback(response)

        put: (resourceName, uid, properties, query, callback) ->
          if !helperValidateResource resourceName
            return
          apiCollectionName = helperGetCollectionName resourceName

          if !_.isUndefined(resourcePool[uid])
            _.extend resourcePool[uid], properties

          properties['uid'] = uid

          socket.apiRequest 'PUT',
            '/' + apiCollectionName,
            query,
            properties, #data
            (response) ->
              if callback
                callback(response)


        delete: (resourceName, uid, query, callback) ->
          if !helperValidateResource resourceName
            return
          apiCollectionName = helperGetCollectionName resourceName

          if !_.isUndefined resourcePool[uid]
            resourcePool[uid].deletedAt = (new Date()).toString()

          socket.apiRequest 'DELETE',
            '/' + apiCollectionName,
            query #query
            uid,  #data
            (response) ->
              callback response
    ]

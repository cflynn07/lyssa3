define [
  'underscore'
], (
  _
) ->

  #Return a function that takes rootScope and attaches global helpers to it
  ($rootScope) ->


    $rootScope.getKeysLength = (obj) ->
      length = 0
      for key, value of obj
        if !_.isUndefined(value['uid']) and _.isNull(value['deletedAt'])
          length++
      return length

    $rootScope.escapeHtml = (str) ->
      div = document.createElement 'div'
      div.appendChild(document.createTextNode(str))
      div.innerHTML

    helperSortHash = (hash, timeProp = 'createdAt') ->
      hashArray       = _.toArray hash
      sortedHashArray = _.sortBy hashArray, (obj) ->
        new Date obj[timeProp]

    $rootScope.getLastObjectFromHash = (hash, timeProp = 'createdAt') ->
      sortedHashArray = helperSortHash hash, timeProp
      _.last sortedHashArray

    $rootScope.getFirstObjectFromHash = (hash, timeProp = 'createdAt') ->
      sortedHashArray = helperSortHash hash, timeProp
      _.first sortedHashArray

    $rootScope.getArrayFromHash = (hash) ->
      resArray = []
      for prop, val of hash
        resArray.push val
      #Sorting?
      return resArray
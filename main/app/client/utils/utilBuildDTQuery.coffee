define [
  'underscore'
], (
  _
) ->

  (searchLikeColumns, sortByColumns, oSettings = false) ->

    query = {}

    sSearch = ''
    if oSettings
      if oSettings and oSettings.oPreviousSearch and oSettings.oPreviousSearch.sSearch
        sSearch = oSettings.oPreviousSearch.sSearch
      query.offset = oSettings._iDisplayStart
      query.limit  = oSettings._iDisplayLength

    query.filter = []
    query.order  = []

    if sSearch.length > 0
      filter = []
      sSearchArr = sSearch.split ' '
      for word in sSearchArr

        for val in searchLikeColumns
          filter.push [val, 'like', word]

      query.filter = filter



    if oSettings
      order = []
      aaSorting = oSettings.aaSorting

      if _.isArray(aaSorting)
        for sortArr in aaSorting

          sortKeyName = ''

          if !_.isUndefined sortByColumns[sortArr[0]]
            sortKeyName = sortByColumns[sortArr[0]]
          else
            continue

          ###
          if sortArr[0] is 0
            sortKeyName = 'firstName'
          else if sortArr[0] is 1
            sortKeyName = 'lastName'
          else if sortArr[0] is 2
            sortKeyName = 'email'
          else if sortArr[0] is 3
            sortKeyName = 'phone'
          else
            continue
          ###

          order.push [sortKeyName, sortArr[1]]
        query.order = order

    return query

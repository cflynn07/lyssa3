define [
  'utils/utilBuildDTQuery'
], (
  utilBuildDTQuery
) ->
  
  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderFieldManageSelectIndividual', ['$scope', 'apiRequest', '$dialog',
      ($scope, apiRequest, $dialog) ->

        #console.log $scope.field

        $scope.dictionaryItemsDT =
          columnDefs: [
            mData:    null
            aTargets: [0]
            mRender: (data, type, full) ->
              return '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].name">' + full.name + '</span>'
          ]
          options:
            bStateSave:      true
            iCookieDuration: 2419200
            bJQueryUI:       false
            bPaginate:       true
            bLengthChange:   false
            bFilter:         true
            bInfo:           true
            bDestroy:        true
            bServerSide:     true
            bProcessing:     true
            fnServerData: (sSource, aoData, fnCallback, oSettings) ->
              query = utilBuildDTQuery ['name'],
                ['name'],
                oSettings

              if query.filter and !_.isUndefined(query.filter[0])
                query.filter[0][3] = 'and'

              query.filter.push ['deletedAt', '=', 'null', 'and']
              query.filter.push ['dictionaryUid', '=', $scope.field.dictionaryUid, 'and']

              cacheResponse   = ''
              oSettings.jqXHR = apiRequest.get 'dictionaryItem', [], query, (response, responseRaw) ->
                if response.code == 200

                  responseDataString = responseRaw #JSON.stringify(response.response)
                  if cacheResponse == responseDataString
                    return
                  cacheResponse = responseDataString

                  dataArr = _.toArray response.response.data

                  fnCallback
                    iTotalRecords:        response.response.length
                    iTotalDisplayRecords: response.response.length
                    aaData:               dataArr

    ]
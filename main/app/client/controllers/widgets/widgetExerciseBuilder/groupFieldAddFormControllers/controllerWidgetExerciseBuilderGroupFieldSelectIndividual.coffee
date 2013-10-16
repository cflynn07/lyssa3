define [
  'utils/utilBuildDTQuery'
], (
  utilBuildDTQuery
) ->

  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderGroupFieldSelectIndividual', ['$scope', 'apiRequest', '$dialog',
      ($scope, apiRequest, $dialog) ->
        $scope.form = {}

        $scope.cancelAddNewField = () ->
          $scope.form = {}
          $scope.formSelectIndividualAdd.$setPristine()
          $scope.$parent.viewModel.cancelAddNewField()

        $scope.isFormInvalid = () ->
          if !$scope.formSelectIndividualAdd
            return
          return $scope.formSelectIndividualAdd.$invalid

        $scope.submitField = () ->
          apiRequest.post 'field', {
            name:          $scope.form.name
            type:          'selectIndividual'
            dictionaryUid: $scope.form.dictionaryUid
            groupUid:      $scope.group.uid
            ordinal:       0
          }, {}, (response) ->
            console.log response
          $scope.cancelAddNewField()

        $scope.removeFieldCorrectDictionaryItems = (uid) ->
          $scope.form.fieldCorrectDictionaryItems.splice($scope.form.fieldCorrectDictionaryItems.indexOf(uid), 1)

        $scope.addToFieldCorrectDictionaryItems = (uid) ->
          if !_.isArray $scope.form.fieldCorrectDictionaryItems
            $scope.form.fieldCorrectDictionaryItems = []
          if $scope.form.fieldCorrectDictionaryItems.indexOf(uid) == -1
            $scope.form.fieldCorrectDictionaryItems.push uid

        $scope.dictionaryListDT =
          columnDefs: [
            mData:    null
            aTargets: [0]
            bSortable: false
            sWidth:   '10px'
            mRender: (data, type, full) ->
              return '<a data-ng-click="form.dictionaryUid = \'' + full.uid + '\'; formSelectIndividualAdd.dictionaryUid.$pristine = false; form.fieldCorrectDictionaryItems = undefined;" class="btn blue">Select</a>'
              #return '<input type="radio" data-required name="dictionary" data-ng-model="form.dictionary" value="' + full.uid + '"></input>' #full.name
          ,
            mData:    null
            aTargets: [1]
            mRender: (data, type, full) ->
              return full.name
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

              query.filter.push ['deletedAt', '=', 'null']

              #console.log query

              cacheResponse   = ''
              oSettings.jqXHR = apiRequest.get 'dictionary', [], query, (response, responseRaw) ->
                #console.log 'response'
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

        $scope.dictionaryItemsListDT =
          columnDefs: [
            mData:    null
            aTargets: [0]
            bSortable: false
            sWidth:   '105px'
            mRender: (data, type, full) ->
              html  = '<div style="width:100%;text-align:center;">'
              html += '<a class="btn green" style="margin-left:auto;margin-right:auto;" data-ng-disabled = "(form.fieldCorrectDictionaryItems && form.fieldCorrectDictionaryItems.indexOf(\'' + full.uid + '\') != -1)" data-ng-click="addToFieldCorrectDictionaryItems(\'' + full.uid + '\'); formSelectIndividualAdd.fieldCorrectDictionaryItems.$pristine = false;"><i class="icon-plus m-icon-white"></i> '
              html += '<span style="color:#FFF !important;" data-ng-hide="(form.fieldCorrectDictionaryItems && form.fieldCorrectDictionaryItems.indexOf(\'' + full.uid + '\') != -1)">Select</span>'
              html += '<span style="color:#FFF !important;" data-ng-show="(form.fieldCorrectDictionaryItems && form.fieldCorrectDictionaryItems.indexOf(\'' + full.uid + '\') != -1)">Selected</span>'
              html += '</a>'
              html += '</div>'
          ,
            mData:    null
            aTargets: [1]
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

              #console.log 'fnServerData'
              #console.log $scope.form.dictionaryUid
              #console.log $scope.form

              if !$scope.form.dictionaryUid
                fnCallback
                  iTotalRecords:        0
                  iTotalDisplayRecords: 0
                  aaData:               []
                return

              if query.filter and !_.isUndefined(query.filter[0])
                query.filter[0][3] = 'and'

              query.filter.push ['deletedAt', '=', 'null', 'and']
              query.filter.push ['dictionaryUid', '=', $scope.form.dictionaryUid, 'and']

              #console.log query

              cacheResponse   = ''
              oSettings.jqXHR = apiRequest.get 'dictionaryItem', [], query, (response, responseRaw) ->
                console.log 'response'
                console.log response
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
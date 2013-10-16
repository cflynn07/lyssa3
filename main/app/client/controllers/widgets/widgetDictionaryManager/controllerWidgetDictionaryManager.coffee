define [
  'jquery'
  'angular'
  'angular-ui'
  'bootstrap'
  'underscore'
  'utils/utilBuildDTQuery'
  'text!views/widgetDictionaryManager/viewWidgetDictionaryManager.html'
  'text!views/widgetDictionaryManager/viewWidgetDictionaryManagerDictionaryItemsButtonsEJS.html'
  'text!views/widgetDictionaryManager/viewWidgetDictionaryManagerListButtonsEJS.html'
  'text!views/widgetDictionaryManager/viewWidgetDictionaryManagerDictionaryItemEditEJS.html'
  'text!views/widgetDictionaryManager/viewWidgetDictionaryManagerArchivedListButtonsEJS.html'
], (
  $
  angular
  angularUi
  bootstrap
  _
  utilBuildDTQuery
  viewWidgetDictionaryManager
  viewWidgetDictionaryManagerDictionaryItemsButtonsEJS
  viewWidgetDictionaryManagerListButtonsEJS
  viewWidgetDictionaryManagerDictionaryItemEditEJS
  viewWidgetDictionaryManagerArchivedListButtonsEJS
) ->
  (Module) ->

    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidgetDictionaryManager', viewWidgetDictionaryManager
    ]

    Module.controller 'ControllerWidgetDictionaryManager',
      ['$scope', '$route', '$routeParams', 'socket', 'apiRequest', '$filter', '$dialog',
        ($scope, $route, $routeParams, socket, apiRequest, $filter, $dialog) ->

          #Trying the object literal as a prop
          #on the scope object approach
          $scope.viewModel =


            submitRenameDictionaryForm: ->
              console.log 'submitRenameDictionaryForm'
              $scope.viewModel.dictionaryRenameForm.submitting = true
              apiRequest.put 'dictionary', $scope.viewModel.routeParams.dictionaryUid, {
                name: $scope.viewModel.dictionaryRenameForm.name
              }, {}, (response) ->
                console.log 'response', response
                $scope.viewModel.closeRenameDictionaryForm();


            closeRenameDictionaryForm: ->
              $scope.viewModel.dictionaryRenameForm = {}
              $scope.viewModel.showRenameDictionary = false
              if $scope.dictionaryRenameForm.$setPristine
                $scope.dictionaryRenameForm.$setPristine()





            dictionaries:               {}

            currentDictionaryUid:       ''
            showAddNewDictionary:       false
            showAddDictionaryItems:     false

            newDictionaryForm:          {}
            newDictionaryItemForm:      {}


            archivedDictionariesListLength: 0
            nonArchivedDictionariesListLength: 0

            restoreDictionary: (uid) ->
              apiRequest.put 'dictionary', uid, {

                deletedAt: null
              }, {}, (response) ->
                console.log response


            archivedDictionaries:
              options: 
                bStateSave:      true
                iCookieDuration: 2419200
                bJQueryUI:       false
                bPaginate:       true
                bLengthChange:   true
                bFilter:         false
                bInfo:           true
                bDestroy:        true
                bServerSide:     true
                bProcessing:     true
                fnServerData: (sSource, aoData, fnCallback, oSettings) ->
                  query = utilBuildDTQuery ['name'],
                    ['name'],
                    oSettings

                  query.filter.push ['deletedAt', '!=', 'null']
                  query.expand = [{
                    resource: 'dictionaryItems'
                  }]

                  cacheResponse   = ''
                  oSettings.jqXHR = apiRequest.get 'dictionary', [], query, (response) ->
                    if response.code == 200

                      $scope.viewModel.archivedDictionariesListLength = response.response.length

                      responseDataString = JSON.stringify(response.response)
                      if cacheResponse == responseDataString
                        return
                      cacheResponse = responseDataString

                      dataArr = _.toArray response.response.data

                      fnCallback
                        iTotalRecords:        response.response.length
                        iTotalDisplayRecords: response.response.length
                        aaData:               dataArr
              columnDefs: [
                mDataProp: 'name'
                aTargets:  [0]
                bSortable: true
                mRender: (data, type, full) ->
                  resHtml  = '<a href="#' + $scope.viewRoot + '/' + $scope.escapeHtml(full.uid) + '">'
                  resHtml += data #+ ' (' + $scope.getKeysLength(full.dictionaryItems) + ')'
                  resHtml += '</a>'
                  return resHtml
              ,
                mData:     null
                bSortable: false
                sWidth:    '100px'
                aTargets:  [1]
                mRender: (data, type, full) ->
                  return $scope.getKeysLength(full.dictionaryItems)
              ,
                mData:     null
                bSortable: false
                aTargets:  [2]
                sWidth:    '100px'
                mRender: (data, type, full) ->
                  uid      = $scope.escapeHtml(full.uid)
                  viewRoot = $scope.viewRoot

                  html = new EJS({text: viewWidgetDictionaryManagerArchivedListButtonsEJS}).render
                    uid:      uid
                    viewRoot: viewRoot
              ]




            dictionaryItemsOptions:
              bStateSave:      true
              iCookieDuration: 2419200
              bJQueryUI:       false
              bPaginate:       true
              bLengthChange:   true
              bFilter:         true
              bInfo:           true
              bDestroy:        true
              bServerSide:     true
              bProcessing:     true
              fnServerData: (sSource, aoData, fnCallback, oSettings) ->
                query = utilBuildDTQuery ['name'],
                  ['name'],
                  oSettings

                if !$scope.viewModel.currentDictionaryUid
                  return


                #TODO: Fix. This is a band-aid quick fix
                if query.filter && query.filter.length 
                  query.filter[0][3] = 'and'


                query.filter.push ['deletedAt', '=', 'null', 'and']
                query.filter.push ['dictionaryUid', '=', $scope.viewModel.currentDictionaryUid, 'and']


                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'dictionaryItem', [], query, (response) ->
                  if response.code == 200

                    responseDataString = JSON.stringify(response.response)
                    if cacheResponse == responseDataString
                      return
                    cacheResponse = responseDataString

                    dataArr = _.toArray response.response.data

                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               dataArr

            dictionaryListOptions:
              bStateSave:      true
              iCookieDuration: 2419200
              bJQueryUI:       false
              bPaginate:       true
              bLengthChange:   true
              bFilter:         false
              bInfo:           true
              bDestroy:        true
              bServerSide:     true
              bProcessing:     true
              fnServerData: (sSource, aoData, fnCallback, oSettings) ->
                query = utilBuildDTQuery ['name'],
                  ['name'],
                  oSettings

                query.filter.push ['deletedAt', '=', 'null']
                query.expand = [{
                  resource: 'dictionaryItems'
                }]

                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'dictionary', [], query, (response) ->
                  if response.code == 200

                    $scope.viewModel.nonArchivedDictionariesListLength = response.response.length

                    responseDataString = JSON.stringify(response.response)
                    if cacheResponse == responseDataString
                      return
                    cacheResponse = responseDataString

                    dataArr = _.toArray response.response.data

                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               dataArr

            columnDefsCurrentDictionaryItems: [
              mDataProp:  "name"
              aTargets:   [0]

              mRender: (data, type, full) ->

                name = 'editDictionaryItemForm' + full.uid.replace /-/g, '_'
                name = $scope.escapeHtml name
                uid  = $scope.escapeHtml full.uid

                html = new EJS(text: viewWidgetDictionaryManagerDictionaryItemEditEJS).render
                  name: name
                  uid:  uid
                  data: data
            ,
              mData:     null
              bSortable: false
              sWidth:    '100px'
              aTargets:  [1]
              mRender: (data, type, full) ->
                name = 'editDictionaryItemForm' + full.uid.replace /-/g, '_'
                name = $scope.escapeHtml name
                uid  = $scope.escapeHtml full.uid.replace /-/g, ''

                html = new EJS({text: viewWidgetDictionaryManagerDictionaryItemsButtonsEJS}).render
                  name: name
                  uid:  uid
                  full: full

                return html
            ]

            columnDefsDictionaryList: [
              mDataProp: 'name'
              aTargets:  [0]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml  = '<a href="#' + $scope.viewRoot + '/' + $scope.escapeHtml(full.uid) + '">'
                resHtml += data #+ ' (' + $scope.getKeysLength(full.dictionaryItems) + ')'
                resHtml += '</a>'
                return resHtml
            ,
              mData:     null
              bSortable: false
              sWidth:    '100px'
              aTargets:  [1]
              mRender: (data, type, full) ->
                return $scope.getKeysLength(full.dictionaryItems)
            ,
              mData:     null
              bSortable: false
              aTargets:  [2]
              sWidth:    '100px'
              mRender: (data, type, full) ->
                uid      = $scope.escapeHtml(full.uid)
                viewRoot = $scope.viewRoot
                html = new EJS({text: viewWidgetDictionaryManagerListButtonsEJS}).render
                  uid:      uid
                  viewRoot: viewRoot
            ]



            closeAddNewDictionary: () ->
              $scope.newDictionaryForm.$setPristine()
              $scope.viewModel.showAddNewDictionary         = false
              $scope.viewModel.newDictionaryForm            = {}
              $scope.viewModel.newDictionaryForm.submitting = false

            postNewDictionary: () ->
              $scope.viewModel.newDictionaryForm.submitting = true
              apiRequest.post 'dictionary', {
                name: $scope.viewModel.newDictionaryForm.name
              }, {}, (response) ->

                $scope.viewModel.closeAddNewDictionary()
                if response.code == 201
                  window.location.href = '#' + $scope.viewRoot + '/' + response.uids[0]


            closeAddNewDictionaryItem: () ->
              $scope.newDictionaryItemForm.$setPristine()
              $scope.viewModel.showAddDictionaryItems           = false
              $scope.viewModel.newDictionaryItemForm            = {}
              $scope.viewModel.newDictionaryItemForm.submitting = false

            postNewDictionaryItem: () ->
              $scope.viewModel.newDictionaryItemForm.submitting = true
              apiRequest.post 'dictionaryItem', {
                dictionaryUid: $scope.viewModel.currentDictionaryUid
                name:          $scope.viewModel.newDictionaryItemForm.name
              }, {}, (response) ->
                $scope.viewModel.closeAddNewDictionaryItem()


          $scope.viewModel.deleteConfirmDialogDictionary = (dictionaryUid) ->
            apiRequest.get 'dictionary', [dictionaryUid], {}, (response) ->
              if response.code == 200
                title = 'Delete Dialog'
                msg   = 'Dire Consequences...'
                btns  = [
                  result:   false
                  label:    'Cancel'
                  cssClass: 'red'
                ,
                  result:   true
                  label:    'Confirm'
                  cssClass: 'green'
                ]
                $dialog.messageBox(title, msg, btns).open()
                  .then (result) ->
                    if result
                      apiRequest.delete 'dictionary', dictionaryUid, {}, (result) ->


          $scope.viewModel.deleteConfirmDialogDictionaryItem = (dictionaryItemUid) ->
            apiRequest.get 'dictionaryItem', [dictionaryItemUid], {}, (response) ->
              title = 'Delete Dialog'
              msg   = 'Dire Consequences...'
              btns  = [
                result:   false
                label:    'Cancel'
                cssClass: 'red'
              ,
                result:   true
                label:    'Confirm'
                cssClass: 'green'
              ]
              $dialog.messageBox(title, msg, btns).open()
                .then (result) ->
                  if result
                    apiRequest.delete 'dictionaryItem', dictionaryItemUid, {}, (result) ->


          $scope.viewModel.cancelEditDictionaryItem = () ->
            $scope.viewModel.editingDictionaryItemTempValue = ''
            $scope.viewModel.editingDictionaryItemUid       = ''

          $scope.viewModel.editDictionaryItem = (dictionaryUid) ->
            $scope.viewModel.editingDictionaryItemUid       = dictionaryUid
            $scope.viewModel.editingDictionaryItemTempValue = $scope.resourcePool[$scope.viewModel.editingDictionaryItemUid].name
          $scope.viewModel.saveEditingDictionaryItem = (isInvalid) ->
            if isInvalid
              return
            apiRequest.put 'dictionaryItem', $scope.viewModel.editingDictionaryItemUid, {
              name: $scope.viewModel.editingDictionaryItemTempValue
            }, {}, (response) ->
              #console.log 'response'
              #console.log response
            $scope.viewModel.cancelEditDictionaryItem()

          $scope.viewModel.editingDictionaryItemUid       = ''
          $scope.viewModel.editingDictionaryItemTempValue = ''


          setCurrentDictionary = () ->
            $scope.viewModel.currentDictionaryUid = $routeParams.dictionaryUid
            #console.log $routeParams

          $scope.$on '$routeChangeSuccess', () ->
            #reset forms...
            $scope.viewModel.showAddDictionaryItems = false
            $scope.newDictionaryItemForm.$setPristine()
            $scope.viewModel.newDictionaryItemForm  = {}

            $scope.viewModel.showAddNewDictionary = false
            $scope.newDictionaryForm.$setPristine()
            $scope.viewModel.newDictionaryForm    = {}

            $scope.viewModel.routeParams = $routeParams          
            setCurrentDictionary()

          $scope.viewModel.routeParams = $routeParams
          setCurrentDictionary()


          #apiRequest.get 'dictionary', [], {expand: [{'resource':'dictionaryItems'}]}, (response) ->
          #  dictArr = response.response.data
          #  $scope.viewModel.dictionaries = dictArr

      ]


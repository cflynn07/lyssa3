define [
  'jquery'
  'angular'
  'ejs'
  'utils/utilBuildDTQuery'
  'utils/utilParseClientTimeZone'
  'utils/utilSafeStringify'
  'underscore'
], (
  $
  angular
  EJS
  utilBuildDTQuery
  utilParseClientTimeZone
  utilSafeStringify
  _
) ->

  (Module) ->

    Module.controller 'ControllerWidgetSchedulerAddExerciseForm', ['$scope', '$route', '$routeParams', 'apiRequest'
      ($scope, $route, $routeParams, apiRequest) ->




        $scope.$watch 'viewModel.newEventForm.eventType', (newVal, oldVal) ->

          if _.isUndefined(newVal)
            return

          viewModel.newEventForm.doneCheckingTemplatesForType = false

          query =
            limit:  1
            offset: 0
            filter: [
              ['deletedAt', '=', 'null',                             'and']
              ['type',      '=', viewModel.newEventForm.eventType,   'and']
            ]
          apiRequest.get 'template', [], query, (response, responseRaw) ->

            viewModel.newEventForm.doneCheckingTemplatesForType = true
            viewModel.newEventForm.templatesForType             = if (response.response.length > 0) then true else false

        , true




        viewModel =
          clientTimeZone:   utilParseClientTimeZone()
          newEventForm:     {}
          activeWizardStep: 0


          isStepValid: (step = false) ->
            if !$scope.newEventForm
              return false
            form = $scope.newEventForm
            if step is false
              step = viewModel.activeWizardStep
            step0Valid = (form.eventType.$valid && form.name.$valid && form.description.$valid && form.date.$valid && viewModel.newEventForm.templatesForType && viewModel.newEventForm.doneCheckingTemplatesForType)
            step1Valid = (form.templateUid.$valid && form.revisionUid.$valid)
            step2Valid = $scope.viewModel.newEventForm.employeeUids && $scope.viewModel.newEventForm.employeeUids.length
            switch step
              when 2
                result = step0Valid && step1Valid && step2Valid
              when 1
                result = step0Valid && step1Valid
              when 0
                result = step0Valid
            return result


          toggleEmployeeToEvent: (employeeUid) ->

            if !_.isArray(viewModel.newEventForm.employeeUids)
              viewModel.newEventForm.employeeUids = []

            empIndex = viewModel.newEventForm.employeeUids.indexOf(employeeUid)
            if empIndex == -1
              viewModel.newEventForm.employeeUids.push employeeUid
            else
              viewModel.newEventForm.employeeUids.splice empIndex, 1


          closeAddNewExerciseForm: () ->
           #console.log 'closeAddNewExerciseForm'
            $scope.viewModel.newEventForm                = {}
            $scope.viewModel.newEventForm.submitting     = false
            $scope.viewModel.activeWizardStep            = 0
            $scope.$parent.viewModel.showNewExerciseForm = false
            $scope.newEventForm.$setPristine()

            $scope.$parent.viewModel.fullCalendarOptions.changeIncrementor++

          submitAddNewExercise: () ->
            $scope.viewModel.newEventForm.submitting = true
            form                                     = viewModel.newEventForm
            apiRequest.post 'event', {
              name:             form.name
              dateTime:         (new Date(form.date).toISOString())
              revisionUid:      form.revisionUid
              participantsUids: form.employeeUids
            }, {}, (eventResponse) ->

              #console.log 'eventResponse'
              #console.log eventResponse

              $scope.viewModel.closeAddNewExerciseForm()
              return

              ###
              if eventResponse.code != 201
                $scope.viewModel.closeAddNewExerciseForm()
                return

              eventUid = ''
              for key, value of eventResponse.uids
                eventUid = value
                break

              insertObjects = []
              for employeeUid in form.employeeUids
                insertObjects.push {
                  eventUid:    eventUid
                  employeeUid: employeeUid
                }

              #console.log 'insertObjects'
              #console.log insertObjects

              apiRequest.post 'eventParticipant', insertObjects, {}, (eventParticipantResponse) ->
                console.log 'eventParticipantResponse'
                console.log eventParticipantResponse
                $scope.viewModel.closeAddNewExerciseForm()
              ###


          templatesListDataTable:
            columnDefs: [
              mData:     null
              aTargets:  [0]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml = '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].name"></span>'
            ,
              mData:     null
              aTargets:  [1]
              bSortable: true
              sWidth:    '45px'
              mRender: (data, type, full) ->
                resHtml = _.str.capitalize(full.type)
            ,
              mData:     null
              aTargets:  [2]
              bSortable: false
              sWidth: '70px'
              mRender: (data, type, full) ->
                html  = '<div class="inline-content">'
                html += '<button class="btn blue" data-ng-click="$parent.viewModel.newEventForm.templateUid = \'' + full.uid + '\'; $parent.newEventForm.templateUid.$pristine = false;">Select</button>'
                html += '</div>'
            ]
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
                query = utilBuildDTQuery ['name', 'type'],
                  ['name', 'type'],
                  oSettings

                #console.log 'a1'

                if _.isUndefined($scope.viewModel.newEventForm) || _.isUndefined($scope.viewModel.newEventForm.eventType)
                  return

               #console.log $scope.viewModel.newEventForm
               #console.log 'p1'

                query.filter.push ['deletedAt', '=', 'null', 'and']
                query.filter.push ['type',      '=', $scope.viewModel.newEventForm.eventType,   'and']

                query.expand = [{
                  resource: 'revisions'
                  expand: [{
                    resource: 'template'
                  }]
                }]

                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'template', [], query, (response, responseRaw) ->

                  if response.code == 200
                    responseDataString = responseRaw #utilSafeStringify(response.response) #JSON.stringify(response.response)JSON.stringify(response.response)

                   #console.log 'utilSafeStringify'
                   #console.log responseDataString

                    if cacheResponse == responseDataString
                      return

                    cacheResponse = responseDataString
                    dataArr = _.toArray response.response.data

                    #console.log 'a3'

                    #console.log dataArr

                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               dataArr

                    #console.log 'a4'


          revisionsListDataTable:
            columnDefs: [
              mData:     null
              aTargets:  [0]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml  = '<span data-ng-bind="resourcePool[resourcePool[\'' + full.uid + '\'].employee.uid].firstName"></span> '
                resHtml += '<span data-ng-bind="resourcePool[resourcePool[\'' + full.uid + '\'].employee.uid].lastName"></span>'
            ,
              mData:     null
              aTargets:  [1]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml = '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].createdAt | date:\'short\'"></span>'
            ,
              mData:     null
              aTargets:  [2]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml = '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].changeSummary"></span>'
            ,
              mData:     null
              aTargets:  [3]
              bSortable: false
              mRender: (data, type, full) ->
                html  = '<div class="inline-content">'
                html += '<button class="btn blue" data-ng-click="$parent.viewModel.newEventForm.revisionUid = \'' + full.uid + '\'; $parent.newEventForm.revisionUid.$pristine = false;">Select</button>'
                html += '</div>'
            ]
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
                query = utilBuildDTQuery [],
                  [],
                  oSettings

                if _.isUndefined($scope.viewModel.newEventForm) || _.isUndefined($scope.viewModel.newEventForm.templateUid)
                  return

                query.filter.push ['deletedAt',   '=', 'null', 'and']
                query.filter.push ['templateUid', '=', $scope.viewModel.newEventForm.templateUid, 'and']
                query.expand = [{resource: 'template'}, {resource: 'employee'}]

                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'revision', [], query, (response, responseRaw) ->

                  if response.code == 200
                    responseDataString = responseRaw #utilSafeStringify(response.response) #JSON.stringify(response.response)

                   #console.log 'utilSafeStringify'
                   #console.log responseDataString

                    if cacheResponse == responseDataString
                      return
                    cacheResponse = responseDataString
                    dataArr = _.toArray response.response.data
                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               dataArr



          employeeListDT:
            options:
              bProcessing:  true
              bStateSave:      true
              iCookieDuration: 2419200 # 1 month
              bPaginate:       true
              bLengthChange:   true
              bFilter:         true
              bInfo:           true
              bDestroy:        true
              bServerSide:     true
              sAjaxSource:     '/'
              fnServerData: (sSource, aoData, fnCallback, oSettings) ->

                query = utilBuildDTQuery ['firstName', 'lastName', 'email', 'phone'],
                  ['firstName', 'lastName', 'email', 'phone'],
                  oSettings

                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'employee', [], query, (response, responseRaw) ->
                  if response.code == 200
                    responseDataString = responseRaw #utilSafeStringify(response.response) #JSON.stringify(response.response)

                   #console.log 'utilSafeStringify'
                   #console.log responseDataString

                    if cacheResponse == responseDataString
                      return
                    cacheResponse = responseDataString
                    empArr = _.toArray response.response.data
                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               empArr

            columnDefs: [
              mData:     null
              bSortable: true
              aTargets:  [0]
              mRender: (data, type, full) ->
                #console.log 'colrender1'
                #console.log arguments
                #return full.firstName
                return '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].firstName">' + full.firstName + '</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [1]
              mRender: (data, type, full) ->
                return '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].lastName">' + full.lastName + '</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [2]
              mRender: (data, type, full) ->
                return '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].email">' + full.email + '</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [3]
              mRender: (data, type, full) ->
                return '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].phone | tel ">' + full.phone + '</span>'
            ,
              mData:     null
              bSortable: false
              aTargets:  [4]
              mRender: (data, type, full) ->
                return '' #<span data-ng-bind="resourcePool[\'' + full.uid + '\'].type">' + full.type + '</span>'
            ,
              mData:     null
              bSortable: false
              sWidth: '70px'
              aTargets:  [5]
              mRender: (data, type, full) ->
                html  = '<div class="inline-content" style = "width:100%; text-align:center;">'
                html += '<button class         = "btn"
                                 data-ng-class = "{true:\'blue\', false:\'red\'}[($parent.viewModel.newEventForm.employeeUids === undefined || $parent.viewModel.newEventForm.employeeUids.indexOf(\'' + full.uid + '\') === -1)]"
                                 data-ng-click = "$parent.viewModel.toggleEmployeeToEvent(\'' + full.uid + '\'); $parent.newEventForm.employeeUids.$pristine = false;">'
                html += '<span style        = "color:#FFF !important;"
                               data-ng-hide = "($parent.viewModel.newEventForm.employeeUids.length && $parent.viewModel.newEventForm.employeeUids.indexOf(\'' + full.uid + '\') != -1)"><i style = "display:inline !important;" class="icon-plus"></i> Select</span>'
                html += '<span style        = "color:#FFF !important;"
                               data-ng-show = "($parent.viewModel.newEventForm.employeeUids.length && $parent.viewModel.newEventForm.employeeUids.indexOf(\'' + full.uid + '\') != -1)"><i style = "display:inline !important;" class="icon-minus"></i> Remove</span>'
                html += '</button>'
                html += '</div>'
            ]





        $scope.viewModel = viewModel

    ]
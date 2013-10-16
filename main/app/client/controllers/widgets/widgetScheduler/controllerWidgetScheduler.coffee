define [
  'jquery'
  'angular'
  'ejs'
  'utils/utilBuildDTQuery'
  'utils/utilParseClientTimeZone'
  'utils/utilSafeStringify'
  'underscore'
  'controllers/widgets/widgetScheduler/controllerWidgetSchedulerAddExerciseForm'

  'text!views/widgetScheduler/viewWidgetScheduler.html'
  'text!views/widgetScheduler/viewWidgetSchedulerListButtonsEJS.html'
  'text!views/widgetScheduler/viewPartialSchedulerAddExerciseForm.html'
], (
  $
  angular
  EJS
  utilBuildDTQuery
  utilParseClientTimeZone
  utilSafeStringify
  _
  ControllerWidgetSchedulerAddExerciseForm

  viewWidgetScheduler
  viewWidgetSchedulerListButtonsEJS
  viewPartialSchedulerAddExerciseForm
) ->

  (Module) ->

    Module.run ['$templateCache',
      ($templateCache) ->
        $templateCache.put 'viewWidgetScheduler',                 viewWidgetScheduler
        $templateCache.put 'viewPartialSchedulerAddExerciseForm', viewPartialSchedulerAddExerciseForm
    ]


    ControllerWidgetSchedulerAddExerciseForm Module 


    Module.controller 'ControllerWidgetScheduler', ['$scope', '$route', '$routeParams', 'apiRequest'
    ($scope, $route, $routeParams, apiRequest) ->

      viewModel =

        exerciseListCollapsed: false
        toggleExerciseListCollapsed: () ->
          console.log 'p2'
          options = {}
          options.direction = 'left'
          if !$scope.viewModel.exerciseListCollapsed
            $('#listPortlet').effect 'blind', {direction:'left'}, () ->

              setTimeout () ->
                $scope.viewModel.exerciseListCollapsed = !$scope.viewModel.exerciseListCollapsed
                if !$scope.$$phase
                  $scope.$apply()
              , 150

          else
            $scope.viewModel.exerciseListCollapsed = !$scope.viewModel.exerciseListCollapsed


        addNewEventForm: {}
        routeParams:     $routeParams
        eventListDT:
          detailRow: (obj) ->
            return ' - '
          columnDefs: [
            mData:     null
            aTargets:  [0]
            bSortable: true
            mRender: (data, type, full) ->
              #return ''
              resHtml = '<a href="#' + $scope.viewRoot + '/' + $scope.escapeHtml(full.uid) + '">'
              if full.name
                resHtml += '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].name">' + $scope.escapeHtml(full.name) + '</span>'
              resHtml += '</a>'
              return resHtml
          ,
            mData:     null
            aTargets:  [1]
            bSortable: true
            sWidth:    '100px'
            mRender: (data, type, full) ->
              #return ''
              resHtml = '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].dateTime | date:\'short\'"></span>'
          ,
            mData:     null
            aTargets:  [2]
            bSortable: true
            sWidth:    '100px'
            mRender: (data, type, full) ->
              #return ''
              resHtml = '<span data-ng-bind="resourcePool[resourcePool[\'' + full.revisionUid + '\'].templateUid].name"></span>'
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
              query = utilBuildDTQuery ['name', 'dateTime'],
                ['name', 'dateTime'],
                oSettings

              query.filter.push ['deletedAt', '=', 'null']
              query.expand = [{resource: 'revision', expand:[{resource: 'template'}]}]

              cacheResponse   = ''
              oSettings.jqXHR = apiRequest.get 'event', [], query, (response, responseRaw) ->
                if response.code == 200
                  responseDataString = responseRaw #utilSafeStringify(response.response) #JSON.stringify(response.response)

                  if cacheResponse == responseDataString
                    return
                  cacheResponse = responseDataString

                  #tempData = _.extend {}, response.response.data
                  dataArr = _.toArray response.response.data

                  fnCallback
                    iTotalRecords:        response.response.length
                    iTotalDisplayRecords: response.response.length
                    aaData:               dataArr








        fullCalendarOptions:
          header:
            right: 'today month,agendaWeek,prev,next'
          eventsResultCache: ''
          changeIncrementor: 0
          events: (start, end, callback) ->
            #console.log 'fetching events...'

            filter  = [['dateTime', '>', (new Date(start).toISOString()), 'and'], ['dateTime', '<', (new Date(end).toISOString())]]
            curDate = new Date()

            apiRequest.get 'event', [], {
              filter: filter
            }, (response, responseRaw, fromCache) ->

              if response.code != 200
                return

              eventsArr = []

              for key, eventObj of response.response.data
                FCEventObj =
                  title:     eventObj.name
                  start:     new Date(eventObj.dateTime)
                  className: if (new Date(eventObj.dateTime) < curDate) then 'event pastEvent' else 'event upcomingEvent'
                  url:       '#' + $scope.viewRoot + '/' + eventObj.uid

                eventsArr.push FCEventObj

              #console.log 'raw check'
              if responseRaw != $scope.viewModel.fullCalendarOptions.eventsResultCache
                $scope.viewModel.fullCalendarOptions.eventsResultCache = responseRaw    #utilSafeStringify(eventsArr) # JSON.stringify(eventsArr)
                #console.log 'raw pass'
                callback eventsArr



        fullCalendarOptionsSecondary:
          header:
            right: 'today month,agendaWeek,agendaDay,prev,next'
          eventsResultCache: {}
          events: (start, end, callback) ->

            filter  = [['dateTime', '>', (new Date(start).toISOString()), 'and'], ['dateTime', '<', (new Date(end).toISOString())]]
            curDate = new Date()

            apiRequest.get 'event', [], {
              filter: filter
            }, (response, responseRaw) ->
              #console.log response
              if response.code != 200
                return

              eventsArr = []

              for key, eventObj of response.response.data
                FCEventObj =
                  title: eventObj.name
                  start: new Date(eventObj.dateTime)
                  className: if (new Date(eventObj.dateTime) < curDate) then 'event pastEvent' else 'event upcomingEvent'
                eventsArr.push FCEventObj

              if responseRaw != $scope.viewModel.fullCalendarOptionsSecondary.eventsResultCache
                $scope.viewModel.fullCalendarOptionsSecondary.eventsResultCache = responseRaw #utilSafeStringify(eventsArr) # JSON.stringify(eventsArr)
                callback eventsArr

      hashChangeUpdate = () ->
        $scope.viewModel.routeParams = $routeParams
      $scope.$on '$routeChangeSuccess', () ->
        hashChangeUpdate()
      $scope.viewModel = viewModel

    ]

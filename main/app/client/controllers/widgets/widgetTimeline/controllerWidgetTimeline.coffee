define [
  'jquery'
  'underscore'
  'utils/utilBuildDTQuery'
  'text!views/widgetTimeline/viewWidgetTimeline.html'
], (
  $
  _
  utilBuildDTQuery
  viewWidgetTimeline
) ->

  (Module) ->

    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidgetTimeline', viewWidgetTimeline
    ]

    Module.controller 'ControllerWidgetTimeline', ['$scope', '$templateCache', 'socket', 'apiRequest', ($scope, $templateCache, socket, apiRequest) ->

      viewModel =
        eventListDT:
          options:
            bProcessing:     true
            bStateSave:      true
            iCookieDuration: 0    #2419200 # 1 month
            bPaginate:       true
            bLengthChange:   true
            bFilter:         true
            bInfo:           true
            bDestroy:        true
            bServerSide:     true
            sAjaxSource:     '/'
            fnServerData: (sSource, aoData, fnCallback, oSettings) ->
              #return
              query = utilBuildDTQuery ['dateTime', 'name'],
                ['dateTime', 'name'],
                oSettings

              query.expand = [{resource: 'eventParticipants', expand: [{resource: 'employee'}]}]

              cacheResponse   = ''
              oSettings.jqXHR = apiRequest.get 'event', [], query, (response, responseRaw) ->
                if response.code != 200
                  return

                if cacheResponse == responseRaw
                  return
                cacheResponse = responseRaw

                empArr = _.toArray response.response.data

                fnCallback
                  iTotalRecords:        response.response.length
                  iTotalDisplayRecords: response.response.length
                  aaData:               empArr
          fnRowCallback: (nRow, aData, iDisplayIndex) ->
            nowDate   = (new Date()).getTime()
            eventDate = (new Date(aData.dateTime)).getTime()

            if nowDate > eventDate
              $(nRow).addClass 'pastEvent'
            else
              $(nRow).addClass 'upcomingEvent'

          # Compute the percentage of eventParticipants that have viewed the exercise
          getInitialViewDateTimePercentage: (uid) ->
            if _.isUndefined($scope.resourcePool[uid]) || _.isUndefined($scope.resourcePool[uid].eventParticipants)
              return '0'

            epReadCount = 0
            for eP in $scope.resourcePool[uid].eventParticipants
              if !_.isNull(eP.initialViewDateTime)
                epReadCount++

            if epReadCount is 0 || $scope.resourcePool[uid].eventParticipants.length is 0
              return '0'

            return (epReadCount / $scope.resourcePool[uid].eventParticipants.length * 1.0) * 100 + ''

          # Compute the percentage of eventParticipants that have completed the exercise
          getfinalizedDateTimePercentage: (uid) ->
            return '0'


          columnDefs: [
              mData:     null
              bSortable: true
              aTargets:  [0]
              sWidth:    '120px'
              mRender: (data, type, full) ->
                #console.log 'colrender1'
                #console.log arguments
                #return full.firstName
                return '<span>{{ resourcePool[\'' + full.uid + '\'].dateTime | date:\'short\' }}</span><br><span>({{ resourcePool[\'' + full.uid + '\'].dateTime | fromNow }})</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [1]
              mRender: (data, type, full) ->
                return '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].name">' + full.name + '</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [2]
              sWidth:    '10%'
              mRender: (data, type, full) ->
                return '<span>{{ (resourcePool[\'' + full.uid + '\'].eventParticipants | toArray).length }}</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [3]
              sWidth:    '120px'
              mRender: (data, type, full) ->

                return '<div class="progress progress-success" style="margin-bottom:0;">
                          <div style="width: {{ $parent.viewModel.eventListDT.getInitialViewDateTimePercentage(\'' + full.uid + '\') }}%;" class="bar"></div>
                        </div>
                        <span>{{ $parent.viewModel.eventListDT.getInitialViewDateTimePercentage(\'' + full.uid + '\') }}%</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [4]
              sWidth:    '120px'
              mRender: (data, type, full) ->
                return '<div class="progress progress-success" style="margin-bottom:0;">
                          <div style="width: {{ $parent.viewModel.eventListDT.getfinalizedDateTimePercentage(\'' + full.uid + '\') }}%;" class="bar"></div>
                        </div>
                        <span>{{ $parent.viewModel.eventListDT.getfinalizedDateTimePercentage(\'' + full.uid + '\') }}%</span>'
            ,
              mData:     null
              bSortable: true
              aTargets:  [5]
              sWidth:    '120px'
              mRender: (data, type, full) ->
                return '<div style = "width:100%; text-align:center;">
                          <a href  = "#{{ viewRoot }}/' + full.uid + '" 
                             class = "btn green">
                            Summary&nbsp;
                            <i class="m-icon-swapright m-icon-white"></i>
                          </a>
                        </div>'
            ]


      $scope.viewModel = viewModel

    ]
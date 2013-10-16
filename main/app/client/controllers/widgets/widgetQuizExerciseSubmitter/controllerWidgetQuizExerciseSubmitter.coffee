define [
  'jquery'
  'angular'
  'ejs'
  'utils/utilBuildDTQuery'
  'text!views/widgetQuizExerciseSubmitter/viewWidgetQuizExerciseSubmitter.html'
  'text!views/widgetQuizExerciseSubmitter/partials/viewPartialQuizExerciseSubmitterOpenResponse.html'
  'text!views/widgetQuizExerciseSubmitter/partials/viewPartialQuizExerciseSubmitterSelectIndividual.html'
  'text!views/widgetQuizExerciseSubmitter/partials/viewPartialQuizExerciseSubmitterSelectMultiple.html'
  'text!views/widgetQuizExerciseSubmitter/partials/viewPartialQuizExerciseSubmitterYesNo.html'
  'text!views/widgetQuizExerciseSubmitter/partials/viewPartialQuizExerciseSubmitterSlider.html'
], (
  $
  angular
  EJS
  utilBuildDTQuery
  viewWidgetQuizExerciseSubmitter
  viewPartialQuizExerciseSubmitterOpenResponse
  viewPartialQuizExerciseSubmitterSelectIndividual
  viewPartialQuizExerciseSubmitterSelectMultiple
  viewPartialQuizExerciseSubmitterYesNo
  viewPartialQuizExerciseSubmitterSlider
) ->

  (Module) ->

    Module.run ['$templateCache',
    ($templateCache) ->

      $templateCache.put 'viewWidgetQuizExerciseSubmitter',                  viewWidgetQuizExerciseSubmitter
      $templateCache.put 'viewPartialQuizExerciseSubmitterOpenResponse',     viewPartialQuizExerciseSubmitterOpenResponse
      $templateCache.put 'viewPartialQuizExerciseSubmitterSelectIndividual', viewPartialQuizExerciseSubmitterSelectIndividual
      $templateCache.put 'viewPartialQuizExerciseSubmitterSelectMultiple',   viewPartialQuizExerciseSubmitterSelectMultiple
      $templateCache.put 'viewPartialQuizExerciseSubmitterYesNo',            viewPartialQuizExerciseSubmitterYesNo
      $templateCache.put 'viewPartialQuizExerciseSubmitterSlider',           viewPartialQuizExerciseSubmitterSlider

    ]






    ###
      Helper controller for select individual form field elements
    ###
    Module.controller 'ControllerWidgetQuizExerciseSubmitter_SelectIndividualHelper', ['$scope', '$route', '$routeParams', 'apiRequest', '$filter'
    ($scope, $route, $routeParams, apiRequest, $filter) ->

      $scope.selectIndividualTable =
        options:
          bStateSave:      true
          iCookieDuration: 0 #2419200
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

            #console.log query

            if !$scope.field.dictionaryUid
              return

            if query.filter.length > 0
              query.filter[0].push 'and'

            query.filter.push ['deletedAt', '=', 'null', 'and']
            query.filter.push ['dictionaryUid', '=', $scope.field.dictionaryUid, 'and']

            cacheResponse   = ''
            oSettings.jqXHR = apiRequest.get 'dictionaryItem', [], query, (response) ->
              if response.code != 200
                return

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
          mData: null
          aTargets: [0]
          mRender: (data, type, full) ->
            return full.name
        ,
          mData: null
          bSortable: false
          aTargets: [1]
          mRender: (data, type, full) ->
            html  = '<button data-ng-click="viewModel.exerciseQuizForm[field.uid] = \'' + full.uid + '\'; viewModel.fields[field.uid].$pristine = false" class="btn blue">'
            html += 'Select'
            html += '</button>'
        ]

    ]






    Module.controller 'ControllerWidgetQuizExerciseSubmitter', ['$scope', '$route', '$routeParams', 'apiRequest', '$filter'
    ($scope, $route, $routeParams, apiRequest, $filter) ->



      getGroupsArrayHelper = () ->
        groupsArray = $filter('deleted')(viewModel.revision.groups)
        groupsArray = $filter('orderBy')(groupsArray, 'ordinal')
        return groupsArray

      moveRevisionGroupHelper = (direction) ->
        if viewModel.activeRevisionGroupUid is ''
            return

        groupsArray = getGroupsArrayHelper()

        for value, key in groupsArray
          if value.uid == viewModel.activeRevisionGroupUid
            if !_.isUndefined(groupsArray[key + direction])
              viewModel.activeRevisionGroupUid = groupsArray[key + direction].uid
            break



      viewModel =

        #Dynamic fields & user-supplied data
        fields:           {}
        exerciseQuizForm: {}

        routeParams:         $routeParams
        eventParticipant:    {}


        revision:            {}
        #Gets set to first group after load, incremented with steps
        activeRevisionGroupUid: ''


        isGroupValidContinue: (groupUid) ->
          if !groupUid || _.isUndefined(viewModel.revision.groups[groupUid])
            return

          groupFields = $filter('deleted')(viewModel.revision.groups[groupUid].fields)

          for value, key in groupFields
            if !$scope.viewModel.fields[value.uid]
              return false
            if !$scope.viewModel.fields[value.uid].$valid
              return false
          return true

        incrementActiveRevisionGroup: () ->
          moveRevisionGroupHelper(1)
        decrementActiveRevisionGroup: () ->
          moveRevisionGroupHelper(-1)

        setActiveRevisionGroup: (groupUid) ->
          if viewModel.activeRevisionGroupUid is ''
            groupsArray = getGroupsArrayHelper()
            if groupsArray.length
              viewModel.activeRevisionGroupUid = groupsArray[0].uid

        ###
          Idea here is to get all submissionFields for this EventParticipant and
          return them as a hash, with the index of the hash being the "Field" uid
          that each submissionField is associated with
        ###
        getSubissionFields: () ->
          eP = $scope.resourcePool[viewModel.routeParams.eventParticipantUid]
          #console.log 'eP.submissionFields'
          #console.log eP.submissionFields

        getEventParticipant: () ->
          if !viewModel.routeParams.eventParticipantUid
            return

          apiRequest.get 'eventParticipant', [viewModel.routeParams.eventParticipantUid], {
            expand: [
              resource: 'submissionFields'
            ,
              resource: 'event'
              expand: [
                resource: 'employee'
              ,
                resource: 'revision'
              ]
            ]
          }, (response) ->
            if response.code != 200
              return
            eP = $scope.resourcePool[viewModel.routeParams.eventParticipantUid]
            if _.isUndefined(eP) || _.isUndefined(eP.event.revision) || _.isUndefined(eP.event.revision.uid)
              return

            apiRequest.get 'revision', [eP.event.revision.uid], {
              expand: [
                resource: 'groups'
                expand: [
                  resource: 'fields'
                ]
              ]
            }, (revisionResponse) ->
              if revisionResponse.code != 200
                return

              viewModel.getSubissionFields()
              viewModel.revision = revisionResponse.response.data
              viewModel.setActiveRevisionGroup()





      viewModel.getEventParticipant()
      $scope.viewModel = viewModel

    ]

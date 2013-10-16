define [
  'text!views/widgetActivityExercisesQuizes/viewWidgetActivityExercisesQuizes.html'
], (
  viewWidgetActivityExercisesQuizes
) ->

  (Module) ->

    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidgetActivityExercisesQuizes',
        viewWidgetActivityExercisesQuizes
    ]

    Module.controller 'ControllerWidgetActivityExercisesQuizes', ['$scope', '$templateCache', 'socket', 'apiRequest', ($scope, $templateCache, socket, apiRequest) ->

      viewModel =
        upcomingQuizesExercises: false
        fetchUpcomingQuizesExercises: () ->
          #console.log 'fetchUpcomingQuizesExercises'
          apiRequest.get 'eventParticipant', [], {
            expand: [{
              resource: 'event'
            }]
            filter: [
              ['employeeUid', '=', $scope.rootUser.uid]
            ]
          }, (response) ->

            console.log 'fetchUpcomingQuizesExercises response'
            console.log response

            if response.code != 200
              return
            viewModel.upcomingQuizesExercises = response.response.data


      viewModel.fetchUpcomingQuizesExercises()


      $scope.$on 'resourcePost', (e, data) ->
        if (data['resourceName'] == 'eventParticipant') || (data['resourceName'] == 'event')
          setTimeout () ->
            $scope.viewModel.fetchUpcomingQuizesExercises()
          , 1000
      $scope.$on 'resourcePut', (e, data) ->
        if (data['resourceName'] == 'eventParticipant') || (data['resourceName'] == 'event')
          setTimeout () ->
            $scope.viewModel.fetchUpcomingQuizesExercises()
          , 1000


      $scope.viewModel = viewModel

    ]

define [
  'jquery'
  'angular'
#  'text!views/widgetExerciseScheduleCalendar/viewWidgetExerciseScheduleCalendar.html'
], (
  $
  angular
#  viewWidgetExerciseScheduleCalendar
) ->

  (Module) ->


    Module.run ['$templateCache',
      ($templateCache) ->
    #    $templateCache.put 'viewWidgetExerciseScheduleCalendar', viewWidgetExerciseScheduleCalendar
    ]


    Module.controller 'ControllerWidgetExerciseScheduleCalendar', ['$scope', '$route', '$routeParams', 'apiRequest'
      ($scope, $route, $routeParams, apiRequest) ->

        

    ]
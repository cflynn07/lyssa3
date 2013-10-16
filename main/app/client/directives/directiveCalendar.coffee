define [
  'jquery'
  'jquery-ui'
  'underscore'
], (
  $
  jqueryUi
  _
) ->

  (Module) ->

    Module.directive 'calendar', () ->
      directive =
        restrict: 'A'
        template: '<div class="calendar"></div>'
        scope:
          options:        '=options'
          activateWatch:  '=activateWatch'
          refetchOnPost:  '@refetchOnPost'
          refetchOnPut:   '@refetchOnPut'
          updateOnChange: '=updateOnChange'
        link: ($scope, element, attrs) ->

          calendarElem = element.find('.calendar')

          activated = false
          activate = () ->
            if activated
              return
            activated = true
            calendarElem.fullCalendar $scope.options



          #Listen for events to refetch events
          $scope.$on 'resourcePost', (e, data) ->
            if data['resourceName'] == $scope.refetchOnPost
              calendarElem.fullCalendar 'refetchEvents'
              #console.log 'refetchEvents'

          $scope.$on 'resourcePut', (e, data) ->
            if data['resourceName'] == $scope.refetchOnPut
              calendarElem.fullCalendar 'refetchEvents'

          $scope.$watch 'updateOnChange', () ->
            #console.log 'change'
            calendarElem.fullCalendar 'redrawEvents'
            calendarElem.fullCalendar 'refetchEvents'

          $scope.$watch 'activateWatch', () ->
            if $scope.activateWatch is true
              activate()
          , true

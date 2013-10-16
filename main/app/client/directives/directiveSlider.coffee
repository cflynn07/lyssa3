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

    Module.directive 'slider', () ->
      directive =
        restrict: 'A'
        template: '<div class="slider"></div>'
        scope:
          options: '=options'
          color: '@color'
        link: ($scope, element, attrs) ->

          sliderElem = element.find('.slider')
          sliderElem.addClass 'bg-' + $scope.color

          sliderElem.slider $scope.options

          #Update value when slider moves
          sliderElem.on 'slidechange', (event, ui) ->
            $scope.$apply () ->
              if !_.isUndefined $scope.options.value
                $scope.options.value = ui.value

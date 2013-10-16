define [
], (
) ->
  
  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderFieldManageSlider', ['$scope', 'apiRequest', '$dialog',
      ($scope, apiRequest, $dialog) ->

        $scope.slider =
          value: 50
          step:  5

        #setInterval () ->
        #  console.log $scope.slider
        #, 500
        
    ]
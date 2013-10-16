define [
], (
) ->
  
  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderGroupFieldPercentageSlider', ['$scope', 'apiRequest', '$dialog',
      ($scope, apiRequest, $dialog) ->
        $scope.form = {}

        $scope.cancelAddNewField = () ->
          $scope.form = {}
          $scope.formPercentageSliderAdd.$setPristine()
          $scope.$parent.viewModel.cancelAddNewField()

        $scope.submitField = () ->
          apiRequest.post 'field', {
            name:                  $scope.form.name
            type:                  'slider'
            percentageSliderLeft:  $scope.form.leftValue
            percentageSliderRight: $scope.form.rightValue
            groupUid:              $scope.group.uid
            ordinal:               0
          }, {}, (response) ->
            console.log response
          $scope.cancelAddNewField()


        $scope.isFormInvalid = () ->
          if !$scope.formPercentageSliderAdd
            return
          return $scope.formPercentageSliderAdd.$invalid

    ]
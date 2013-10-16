define [
], (
) ->

  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderGroupFieldYesNo', ['$scope', 'apiRequest', '$dialog',
      ($scope, apiRequest, $dialog) ->
        $scope.form = {}

        $scope.cancelAddNewField = () ->
          $scope.form = {}
          $scope.formYesNoAdd.$setPristine()
          $scope.$parent.viewModel.cancelAddNewField()
    ]
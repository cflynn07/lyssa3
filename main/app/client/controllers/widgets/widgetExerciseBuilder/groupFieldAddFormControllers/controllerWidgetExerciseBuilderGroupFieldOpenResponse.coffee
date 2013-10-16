define [
], (
) ->

  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderGroupFieldOpenResponse', ['$scope', 'apiRequest', '$dialog',
      ($scope, apiRequest, $dialog) ->

        $scope.form = {}

        $scope.cancelAddNewField = () ->
          $scope.form = {}
          $scope.formOpenResponseAdd.$setPristine()
          $scope.$parent.viewModel.cancelAddNewField()

        $scope.submitField = () ->
          apiRequest.post 'field', {
            name:     $scope.form.name
            type:     'openResponse'
            groupUid: $scope.group.uid
            ordinal:  0
            openResponseMaxLength: $scope.form.maxLength
            openResponseMinLength: $scope.form.minLength
          }, {}, (response) ->
            console.log response

            apiRequest.get 'group', [$scope.group.uid], {expand:[{
              resource: 'fields'
            }]}, (response) ->
              console.log 'updated group'
              console.log response

            $scope.cancelAddNewField()

        $scope.isFormInvalid = () ->
          if !$scope.formOpenResponseAdd
            return
          return $scope.formOpenResponseAdd.$invalid
    ]

define [
  'jquery'
  'jquery-ui'
  'underscore'
  'text!views/widgetEmployeeManager/viewPartialEmployeeManagerEditEmployeeEJS.html'
], (
  $
  jqueryUi
  _
  viewPartialEmployeeManagerEditEmployeeEJS
) ->

  (Module) ->

    Module.directive 'editEmployee', (apiRequest) ->
      directive =
        restrict: 'A'
        template: viewPartialEmployeeManagerEditEmployeeEJS
        scope:
          employeeUid:    '@employeeUid'
          resourcePool:   '=resourcePool'
          clientOrmShare: '=clientOrmShare'
        link: ($scope, element, attrs) ->

          $scope.subViewModel  = {}


          $scope.editEmployee                  = $scope.resourcePool[$scope.employeeUid]
          $scope.subViewModel.editEmployeeForm = _.extend {}, $scope.editEmployee


          $scope.$watch 'subViewModel', ->
            #Runs once at initialization, set to true for first run
            if _.isUndefined $scope.dataIsSynced
              $scope.dataIsSynced = true
            else 
              $scope.dataIsSynced = false

            console.log '$scope.dataIsSynced'
            console.log $scope.dataIsSynced

          , true

          $scope.subViewModel.updateEmployee = () ->
            $scope.updateInProgress = true

            apiRequest.put 'employee', $scope.editEmployee.uid, {
              firstName: $scope.subViewModel.editEmployeeForm.firstName
              lastName:  $scope.subViewModel.editEmployeeForm.lastName
              email:     $scope.subViewModel.editEmployeeForm.email
              phone:     $scope.subViewModel.editEmployeeForm.phone
            }, (response) ->
              #console.log response
              $scope.dataIsSynced         = true
              $scope.updateInProgress     = false
              $scope.updateActionComplete = true


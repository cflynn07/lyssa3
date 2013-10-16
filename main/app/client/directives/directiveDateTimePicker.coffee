define [
  'jquery'
  'jquery-ui'
], (
  $
  jqueryUi
) ->

  (Module) ->

    #http://www.malot.fr/bootstrap-datetimepicker

    Module.directive 'dateTimePicker', () ->
      directive =
        restrict:   'A'
        scope:
          model:  '=model'
          form:   '=form'
        replace: true
        link: ($scope, element, attrs) ->

          element.datetimepicker({
            showMeridian: true
            startDate:    new Date()
            autoclose:    true
            minuteStep:   1
            format:       'dd MM yyyy - HH:ii P'
          }).on 'changeDate', (e) ->

            d1 = new Date(e.date)
            d2 = new Date(d1.getTime() + (d1.getTimezoneOffset() * 60000))
            d2 = new Date(d2.setSeconds(0))

            #console.log d2

            $scope.$apply () ->
              $scope.model = d2
              $scope.form.$pristine = false

            #console.log arguments

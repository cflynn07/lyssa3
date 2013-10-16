define [
  'jquery'
  'jquery-ui'
], (
  $
  jqueryUi
) ->

  (Module) ->

    Module.directive 'datepicker', () ->
      directive =
        restrict:   'A'
        #transclude: false
        #template:   ''
        scope:
          months: '@months'
          model:  '=model'
        replace: true
        link: (scope, iterStartElement, attrs) ->


          iterStartElement.datepicker(
            dateFormat: 'yy-mm-dd'
            numberOfMonths: parseInt(scope.months || 1) #2 #scope.months
            onSelect: (dateText, inst) ->

              console.log arguments

              scope.$apply (scope) ->
                scope.model = dateText
                return
          )
              #$parse()

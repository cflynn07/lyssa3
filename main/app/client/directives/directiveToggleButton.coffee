define [
  'jquery'
  'bootstrap-toggle-buttons'
], (
  $
  bootstrapToggleButtons
) ->

  (Module) ->

    Module.directive 'toggleButton', () ->
      directive =
        restrict:   'A'
        template:   '<div><input type="checkbox" ></div>'
        scope:
          title:        '@valueLink'

        replace: true
        link: (scope, iterStartElement, attrs) ->

          iterStartElement.addClass 'toggle'
          iterStartElement.toggleButtons()

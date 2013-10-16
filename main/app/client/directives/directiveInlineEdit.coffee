define [
  'jquery'
  'text!views/viewsDirectives/viewDirectiveInlineEdit.html'
], (
  $
  viewDirectiveInlineEdit
) ->

  (Module) ->

    Module.directive 'inlineEdit', () ->
      directive =
        restrict: 'A'
        template: viewDirectiveInlineEdit
        scope:
          model: '='
        link: (scope, elm, attrs) ->

          elm.bind 'keypress', (e) ->
            if e.charCode is 13
              scope.$apply () ->
                scope.editMode = false

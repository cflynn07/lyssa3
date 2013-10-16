define [
  'jquery'
  'text!views/viewsDirectives/viewCollapseWidget.html'
], (
  $
  viewCollapseWidget
) ->

  (Module) ->

    Module.directive 'collapseWidget', () ->
      directive =
        restrict:   'A'
        transclude: true
        template:   viewCollapseWidget
        scope:
          title:        '@title'
          widgetThemis: '@widgetThemis'
          color:        '@color'
          model:        '='

        #replace: true
        compile: (element, attrs, transclusionFunc) ->
          (scope, iterStartElement, attrs) ->
            console.log 'cw link f'
            #if scope.buttons
              #console.log scope.buttons
            scope.collapsed = false

            scope.toggle = () ->
              scope.collapsed = !scope.collapsed

            origElem   = transclusionFunc scope
            content    = origElem.text()
            scope.orig = content
            scope.obj  = content

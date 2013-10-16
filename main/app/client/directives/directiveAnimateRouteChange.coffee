define [
  'jquery'
], (
  $
) ->
  (Module) ->

    Module.directive 'animateRouteChange', () ->
      (scope, element, attrs) ->

        scope.$on '$routeChangeSuccess', (event, current, previous) ->
          hash = window.location.hash
          menuHash = element.find('> a').attr 'data-ng-href'
          if hash.indexOf(menuHash) is 0
            if element.find('.sub > li').length > 0 and !element.find('.sub').is(':visible')
              element.find('.sub').hide().slideDown 'fast'
          else
            if element.find('.sub > li').length > 0
              element.find('.sub').slideUp 'fast'

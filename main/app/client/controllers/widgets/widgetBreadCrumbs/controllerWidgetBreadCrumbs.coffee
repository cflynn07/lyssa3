define [
  'angular'
  'text!views/widgetBreadCrumbs/viewWidgetBreadCrumbs.html'
  'text!views/widgetBreadCrumbs/viewNoBreadCrumbs.html'
], (
  angular
  viewWidgetBreadCrumbs
  viewNoBreadCrumbs
) ->
  (Module) ->

    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidgetBreadCrumbs', viewWidgetBreadCrumbs
      $templateCache.put 'viewNoBreadCrumbs',     viewNoBreadCrumbs
    ]

    Module.controller 'ControllerWidgetBreadCrumbs', ['$scope', '$templateCache', 'socket', ($scope, $templateCache, socket) ->
      $scope.title    = 'Themis'
      $scope.subtitle = 'by Cobar Systems LLC'
    ]

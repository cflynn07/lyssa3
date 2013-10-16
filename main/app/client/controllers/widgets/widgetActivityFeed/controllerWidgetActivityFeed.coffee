define [
  'angular'
  'jquery'
  'text!views/widgetActivityFeed/viewWidgetActivityFeed.html'
  'text!views/widgetActivityFeed/partials/viewPartialActivityFeedCreateDictionary.html'
  'text!views/widgetActivityFeed/partials/viewPartialActivityFeedCreateEmployee.html'
  'text!views/widgetActivityFeed/partials/viewPartialActivityFeedCreateEvent.html'
  'text!views/widgetActivityFeed/partials/viewPartialActivityFeedEventInitialized.html'
], (
  angular
  $
  viewWidgetActivityFeed
  viewPartialActivityFeedCreateDictionary
  viewPartialActivityFeedCreateEmployee
  viewPartialActivityFeedCreateEvent
  viewPartialActivityFeedEventInitialized
) ->
  (Module) ->

    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidgetActivityFeed',                  viewWidgetActivityFeed
      $templateCache.put 'viewPartialActivityFeedCreateDictionary', viewPartialActivityFeedCreateDictionary
      $templateCache.put 'viewPartialActivityFeedCreateEmployee',   viewPartialActivityFeedCreateEmployee
      $templateCache.put 'viewPartialActivityFeedCreateEvent',      viewPartialActivityFeedCreateEvent
      $templateCache.put 'viewPartialActivityFeedEventInitialized', viewPartialActivityFeedEventInitialized
    ]

    Module.controller 'ControllerWidgetActivityFeed', ['$scope', '$templateCache', 'socket', 'apiRequest', ($scope, $templateCache, socket, apiRequest) ->
      $scope.title    = 'Themis'
      $scope.subtitle = 'by Cobar Systems LLC'

      $scope.fetchActivity()
    ]

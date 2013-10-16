define [
  'jquery'
  'underscore'
  'angular'
  'text!views/widgetLeftMenu/viewWidgetCoreLeftMenu.html'
  'text!views/widgetLeftMenu/viewWidgetCoreLeftMenuOptionsAdmin.html'
  'text!views/widgetLeftMenu/viewWidgetCoreLeftMenuOptionsDelegate.html'
  'config/clientConfig'
], (
  $
  _
  angular
  viewWidgetCoreLeftMenu
  viewWidgetCoreLeftMenuOptionsAdmin
  viewWidgetCoreLeftMenuOptionsDelegate
  clientConfig
) ->

  (Module) ->

    Module.run ['$templateCache',
    ($templateCache) ->
      $templateCache.put 'viewWidgetCoreLeftMenu',
        viewWidgetCoreLeftMenu
      $templateCache.put 'viewWidgetCoreLeftMenuOptionsAdmin',
        viewWidgetCoreLeftMenuOptionsAdmin
      $templateCache.put 'viewWidgetCoreLeftMenuOptionsDelegate',
        viewWidgetCoreLeftMenuOptionsDelegate
    ]


    Module.controller 'ControllerWidgetCoreLeftMenu', ['$scope', '$rootScope', '$route', '$templateCache', '$location',
    ($scope, $rootScope, $route, $templateCache, $location) ->

      if $scope.quizMode
        return

      $rootScope.sidebarClosedToggle = () ->
        $rootScope.sidebarClosed = !$rootScope.sidebarClosed

      $scope.menuChoices = []

      $scope.currentActiveMenuItem = ''
      $scope.setCurrentActiveMenuItem = (item) ->
        if $scope.currentActiveMenuItem == item
          $scope.currentActiveMenuItem = ''
        else
          $scope.currentActiveMenuItem = item


      ###
      for key, value of clientConfig.routes
        if clientConfig.routeMatchClientType(key, $scope.rootUser.type)
          menuObj       = {}
          menuObj.hash  = key
          menuObj.title = value.title

          $scope.menuChoices.push menuObj

      [{
        hash: 'menu1a'
        title: 'Menu Option 1'
        sub: [{
          hash: 'menu1a'
          title: 'Menu Option 1'
        },{
          hash: 'menu1a/sub1'
          title: 'Menu Option 1sub'
        }]
      },{
        hash: 'menu2'
        title: 'Menu Option 2'
      },{
        hash: 'menu3'
        title: 'Menu Option 3'
      }]
      ###

      $scope.getClass    = (menuTitle, isTop) ->
        className = ''
        if isTop
          if $scope.activeMenuItem.indexOf(menuTitle) == 0
            className = 'active'
        #else
        #  if $scope.activeMenuItem == menuTitle
        #    className = 'active'
        return className

      $scope.updateActiveMenuItem = () ->
        $scope.locationHash = $location.$$path
        ###
        $scope.activeMenuItem    = ''
        #$scope.activeSubMenuItem = ''
        if !_.isUndefined($route.current) and !_.isUndefined($route.current.pathValue)
          $scope.activeMenuItem = $route.current.pathValue.title
          $scope.locationHash   = $location.$$path
          #console.log '$location.$$path'
          #console.log $location.$$path
        ###

      $scope.$on '$routeChangeSuccess', (scope, current, previous) ->
        $scope.updateActiveMenuItem()
      $scope.updateActiveMenuItem()
    ]

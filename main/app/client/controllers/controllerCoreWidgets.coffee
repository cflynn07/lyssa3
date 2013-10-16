define [
  'angular'
  'jquery'
  'underscore'
  'text!views/viewCoreWidgets.html'
  'config/clientConfig'
], (
  angular
  $
  _
  viewCoreWidgets
  clientConfig
) ->

  (Module) ->

    Module.run ['$templateCache', 'apiRequest', '$routeParams', '$route',
    ($templateCache, apiRequest, $routeParams, $route) ->
      $templateCache.put 'viewCoreWidgets', viewCoreWidgets
    ]

    ###
      Manages the dynamic insertion of widgets to the main content area of the application
    ###
    Module.controller 'ControllerCoreWidgets', ['$scope', '$route', '$rootScope',
    ($scope, $route, $rootScope) ->


      #primaryWidgetRow      = [{widget: 'viewWidgetBreadCrumbs', spanLength:'span12'}]
      primaryWidgetRow       = []
      $scope.widgetRows      = [primaryWidgetRow]
      previousRouteGroup     = ''
      $rootScope.widgetsData = {}

      isDerivativeRoute   = (newRouteTitle) ->
        result = true

        if newRouteTitle != previousRouteGroup
          result = false
          previousRouteGroup = newRouteTitle
        return result

      stripAllButBC = () ->
        $scope.widgetRows = [primaryWidgetRow]

      trigger4oh4 = () ->
        widgets = stripAllButBC()
        widgets.push widget:'viewWidget4oh4'
        $scope.widgetRows = widgets
        previousRouteGroup = ''

      loadNewRoute = () ->

        existingFadeIns = $('.animated.fadeInRightBig')


        loadNewRouteChangeCallback = ->
          #console.log $route
          #Determine if this is a valid application route
          if _.isUndefined($route.current.$$route)
            if previousRouteGroup == '' && $scope.rootUser
              window.location.hash = '/' + clientConfig.simplifiedUserCategories[$scope.rootUser.type] + '/themis'
              return
            else
              trigger4oh4()
              return


          #if !clientConfig.isRouteQuiz($route.current.path)
            #Determine if this is a valid route for the given user-type
            #console.log 'routeMatchClientType'
            #if !clientConfig.routeMatchClientType($route.current.path, $scope.rootUser.type)
            #  trigger4oh4()
            #  return

          #if !isDerivativeRoute($route.current.pathValue.title)

          if $route.current.$$route.group != previousRouteGroup
            previousRouteGroup = $route.current.$$route.group

            $('body').animate({scrollTop: 0}, 700)

            widgets = stripAllButBC()

            if !$route.current.$$route.widgetViews || !$route.current.$$route.widgetViews.length
              return

            $rootScope.widgetsData = {}

            for rowWidgets in $route.current.$$route.widgetViews

              widgetObjects = []
              for widget in rowWidgets
              
                spanLength = 'span12'
                if rowWidgets.length == 2
                  spanLength = 'span6'

                #Mesh that data in there                
                widgetObjects.push {
                  spanLength: spanLength
                  widget:     widget.name
                }
                $rootScope.widgetsData[widget.name] = widget.data


              $scope.widgetRows.push widgetObjects
              #if $route.current.$$route.widgetData 
              #  $scope.widgetData = $route.current.$$route.widgetData 


            #Used by widgets for forming links
            $rootScope.viewRoot = $route.current.$$route.root


        ###
        if existingFadeIns.length
          existingFadeIns.addClass 'fadeOutDownBig'
          setTimeout () ->
            loadNewRouteChangeCallback()
            $scope.$apply()
          , 200
        else 
        ###

        loadNewRouteChangeCallback()

        








      $scope.$on '$routeChangeSuccess', (event, current, previous) ->
        loadNewRoute()

      loadNewRoute()


    ]

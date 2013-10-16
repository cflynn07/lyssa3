define [
  'jquery'
  'underscore'
  'angular'
  'config/clientConfig'
  'config/clientConfigHelperMethods'
  'text!views/viewCore.html'
  'text!config/clientOrmShare.json'
], (
  $
  _
  angular
  clientConfig
  clientConfigHelperMethods
  viewCore
  clientOrmShare
) ->

  #Server dumps out JSON of ORM objects in a text file. Parse it to get object literal.
  clientOrmShare = JSON.parse clientOrmShare

  (Module) ->

    Module.run ['$templateCache',
    ($templateCache) ->
      $templateCache.put 'viewCore', viewCore
    ]

    Module.controller 'ControllerApp' , ['$rootScope', '$route', '$routeParams', 'socket', 'authenticate',
    ($rootScope, $route, $routeParams, socket, authenticate) ->


      #Attach some helper methods to the rootScope to be used in views throughout
      #the application
      clientConfigHelperMethods $rootScope

      #routes and other configurable values
      $rootScope.clientConfig = clientConfig

      #ORM objects properties/validation rules
      $rootScope.clientOrmShare = clientOrmShare

      $rootScope.rootStatus = 'food';




      #quick hack
      $('body').removeClass 'login'
      $('body').css('background-color', '#444').animate({'background-color':'#F1F1F1'}, 'slow')

      $rootScope.rootStatus         = 'loading'
      $rootScope.loadingStatus      = 'Connecting...'
      $rootScope.loadingStatusColor = '#35aa47 !important'
      $rootScope.loadingStatusIcon  = 'icon-lock'
      $rootScope.routeParams        = $routeParams

      $rootScope.$on '$routeChangeSuccess', (event, current, previous) ->
        $rootScope.routeParams = $routeParams




      #Get status, determine if user is authenticated or not.
      #unauthenticated shows login prompt, authenticated shows application
      socket.emit 'authenticate:status', {}, (response) ->
        if response.authenticated and response.user
          authenticate.authenticate response.user
        else
          authenticate.unauthenticate()

    ]

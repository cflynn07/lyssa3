define [
], (
) ->

  (Module) ->
    Module.factory 'authenticate', ['$rootScope', 'socket', 'apiRequest'
    ($rootScope, socket, apiRequest) ->

      factory =
        authenticate: (user) ->
          $rootScope.rootStatus   = 'authenticated'
          $rootScope.rootUser     = user
          $rootScope.rootEmployee = {}
          $rootScope.rootClient   = {}

          apiRequest.get 'employee', [user.uid], {expand:[{resource: 'client'}]}, (response) ->
            if response.code == 200
              $rootScope.rootEmployee = response.response.data
              $rootScope.rootClient   = $rootScope.rootEmployee.client

        unauthenticate: () ->
          socket.emit 'authenticate:unauthenticate', {}, () ->
            $rootScope.rootStatus   = 'login'
            $rootScope.rootUser     = {}
            $rootScope.rootEmployee = {}
            $rootScope.rootClient   = {}
            #$rootScope.resourcePool           = {}
            #$rootScope.resourceCollectionPool = {}

    ]

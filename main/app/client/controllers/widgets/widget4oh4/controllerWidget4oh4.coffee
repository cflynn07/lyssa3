define [
  'angular'
  'text!views/widget4oh4/viewWidget4oh4.html'
], (
  angular
  viewWidget4oh4
) ->

  (Module) ->


    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidget4oh4', viewWidget4oh4
    ]

    Module.controller 'ControllerWidget4oh4', ['$scope', '$route', ($scope, $route) ->



    ]

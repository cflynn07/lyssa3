define [
  'text!views/widgetTabs/viewWidgetTabs.html'
], (
  viewWidgetTabs
) -> 
  
  (Module) ->

    Module.run ['$templateCache', ($templateCache) ->
      $templateCache.put 'viewWidgetTabs', viewWidgetTabs
    ]

    Module.controller 'ControllerWidgetTabs', ['$scope', '$rootScope', 'socket', 'apiRequest', ($scope, $rootScope, socket, apiRequest) ->

      #Attach sub-widgets data to rootScope.widgetsData to emulate normal root-lvl 
      #loading of widgets
      for widget in $scope.widgetsData['viewWidgetTabs'].tabs
        $rootScope.widgetsData[widget.widgetName] = widget.data

      viewModel        = {}
      $scope.viewModel = viewModel;

      viewModel.data   = $rootScope.widgetsData['viewWidgetTabs']
      
    ]
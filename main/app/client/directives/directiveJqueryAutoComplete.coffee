define [
  'jquery'
  'jquery-ui'
], (
  $
  $ui
) ->

  (Module) ->

    Module.directive "jqueryAutoComplete", ($compile) ->
      directive =
        restrict: 'A'
        scope: 'isolate'
        link: (scope, element, attrs) ->

          element.autocomplete(
            source: (request, response) ->
              response([{name: 'foo'},{name: 'foo2'}])
            minLength: 2
            focus: () ->
              false
            select: (event, ui) ->
              this.value = ui.item.name
              return false
          ).data('ui-autocomplete')._renderItem = (ul, item) ->
            console.log ul
            console.log item
            return $('<li>').html('<a>food</a>').appendTo ul
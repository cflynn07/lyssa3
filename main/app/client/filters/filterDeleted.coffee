define [
  'underscore'
], (
  _
) ->

  #https://github.com/angular/angular.js/issues/1286
  (Module) ->

    Module.filter 'deleted', () ->
      (arr) ->

        return _.filter arr, (item) ->
          !item.deletedAt



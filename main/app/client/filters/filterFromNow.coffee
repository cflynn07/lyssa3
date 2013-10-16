define [
  'underscore'
  'moment'
], (
  _
  moment
) ->

  #https://github.com/angular/angular.js/issues/1286
  (Module) ->

    Module.filter 'fromNow', () ->
      (dateString) ->
        if !dateString
          return ''

        moment(new Date(dateString)).fromNow()

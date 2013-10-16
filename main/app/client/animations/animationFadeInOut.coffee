define [
  'jquery'
  'angular'
], (
  $
  angular
) ->

  (Module) ->

    Module.animation 'fade-out', ['$rootScope', ($rootScope) ->
      animation =
        setup: (element) ->
          #element.css display: 'none'
        start: (element, done) ->
          element.removeClass 'fadeIn'
          element.show().addClass 'animated fadeOut' 
          done()
          #element.fadeOut 'fast', () ->
          #  done()
    ]

    Module.animation 'fade-in', ['$rootScope', ($rootScope) ->
      #console.log 'animationInit'
      animation =
        setup: (element) ->
          element.css display: 'none'
        start: (element, done, memo) ->
          element.removeClass 'fadeOut'
          element.show().addClass 'animated fadeIn' 
          done()
          #element.fadeIn 'fast', () ->
          #  done()
    ]


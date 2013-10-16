define [
  'jquery'
  'angular'
], (
  $
  angular
) ->

  (Module) ->

    Module.animation 'slide-up', ['$rootScope', ($rootScope) ->
      animation =
        setup: (element) ->
          #element.css display: 'none'
        start: (element, done) ->
          element.slideUp 'normal', () ->
            done()
    ]

    Module.animation 'slide-down', ['$rootScope', ($rootScope) ->
      #console.log 'animationInit'
      animation =
        setup: (element) ->
          element.css display: 'none'
        start: (element, done, memo) ->
          element.slideDown 'normal', () ->
            done()
    ]

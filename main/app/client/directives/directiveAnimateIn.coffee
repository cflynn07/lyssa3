define [
  'jquery'
], (
  $
) ->

  (Module) ->

    Module.directive 'animateIn', () ->
      (scope, element, attrs) ->

        element.addClass 'animated fadeIn'
        #return


        #console.log 'p1'
        loadingHTML = "<div class=\"loading-indicator\">
          <div class=\"progress progress-striped active\">
            <div style=\"width: 100%;\" class=\"bar\"></div>
          </div>
        </div>"
        #element.find('> .portlet-body').prepend loadingHTML

        num = 0
        $el = element

        $el.removeClass 'widget-themis-finish'
        $el.addClass    'widget-themis'
        $el.css         'position', 'relative'

        #$el.hide().fadeIn()
        #element.find('.loading-indicator').hide()#fadeOut('fast')

        timer = setInterval(() ->
          max = 4
          num = num + 1
          $el = element
          init_opacity = 1 #0.6 #parseFloat $el.css 'opacity'

          if num > max
            #setTimeout(() ->
            #  $el.find('.loading-indicator').remove()
            #, 100)
            clearTimeout    timer
            $el.removeClass 'widget-themis'
            $el.addClass    'widget-themis-finish'
            $el.css         'position', ''
            return

          #$el.find('.loading-indicator').css
          #  opacity: 1.0 - (num / max)

          $el.css
            'border-right': '0px !important'
            'box-shadow':   num + 'px ' + num + 'px 0 0 rgba(0,0,0,0.35)'
            top:            (4 - num) + 'px'
            left:           (4 - num) + 'px'
          #  opacity: init_opacity + ((1.0 - init_opacity) * (num / max))

        , 50)


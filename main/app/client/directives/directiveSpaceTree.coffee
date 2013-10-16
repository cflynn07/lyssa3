define [
  'jquery'
  'angular'
  'underscore'
  'underscore_string'
  'spacetree'
], (
  $
  angular
  _
  underscore_string
  $jit
) ->

  (Module) ->

    Module.directive "spaceTree", ($compile) ->
      directive =
        restrict: 'A'
        scope: 'isolate'
        link: (scope, element, attrs) ->



          json =
            id: 'node02'
            name: 'Acme Corporation'
            data: {}
            children: [{
              id: 'node03'
              name: 'Accounting'
              data: {}
              children: [
                id:       'nodea1'
                name:     'brazin'
                data:     {}
                children: []
              ]
            },{
              id: 'node04'
              name: 'Manufacturing Ops'
              data: {}
              children: [
                id:       'nodea1'
                name:     'brazin'
                data:     {}
                children: []
              ]
            },{
              id: 'node05'
              name: 'Sales'
              data: {}
              children: []
            }]




          id = 'food' #'spacetree_' + Math.random(1000)
          element.attr 'id', id

          st = new $jit.ST
            injectInto:    id
            duration:      500
            transition:    $jit.Trans.Quart.easeInOut
            levelDistance: 100
            #orientation: 'top'
            Navigation:
              enable:  true
              panning: true
            Node:
              #height:      20
              width:       200
              #autoWidth:   true
              autoHeight:  true
              type:        'rectangle'
              color:       '#4b8df8'
              overridable: true
            Edge:
              type:        'bezier'
              overridable: true
            onBeforeCompute: (node) ->
              console.log '---'
              console.log node.name
            onAfterCompute: () ->
              console.log 'done'
            onCreateLabel: (label, node) ->
              console.log node
              console.log label
              label.id               = node.id
              label.innerHTML        = node.name
              label.style.width      = '200px'
              #label.style.height     = '17px'
              label.style.color      = '#FFF'
              label.style.fontSize   = '12px'
              label.style.textAlign  = 'center'


            onBeforePlotNode: (node) ->
            onBeforePlotLine: (adj) ->



          st.loadJSON json
          st.compute()
          st.onClick st.root



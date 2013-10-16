define [
  'jquery'
  'angular'
  'datatables'
  'datatables_bootstrap'
  'underscore'
  'underscore_string'
], (
  $
  angular
  dataTables
  dataTables_bootstrap
  _
  underscore_string
) ->

  (Module) ->

    Module.directive "dataTable", ($compile) ->
      directive =
        restrict: 'A'
        scope: 'isolate'
        link: (scope, element, attrs) ->

          bindDetailCallbacks = () ->
            element.find('.detail').unbind('click').bind 'click', () ->

              $el   = $(this).parents('tr')
              el    = $el.get(0)
              _this = this

              if dataTable.fnIsOpen el

                detailRow = $el.find('+ tr:first')
                detailRow.find('> td > div').slideUp () ->

                  $(_this).addClass 'blue'
                  $(_this).removeClass 'black'

                  dataTable.fnClose el
                  $el.find('.m-icon-swapup').hide()
                  $el.find('.m-icon-swapdown').fadeIn()

              else

                $el.find('.m-icon-swapdown').hide()
                $el.find('.m-icon-swapup').fadeIn()

                $(this).removeClass 'blue'
                $(this).addClass 'black'


                data     = dataTable.fnGetData el
                html     = scope.$parent.viewModel[attrs['parentDataTableViewModelProp']].detailRow(data)
                accessor = 'detailRow' + data.uid
                dataTable.fnOpen el, '', accessor + ' details'

                #trim it
                #If there's any white space around the HTML this causes a nasty error
                html = _.str.trim(html)

                accessor   = '.' + accessor
                newElement = element.find accessor
                newElement.html $compile(html)(scope)

                newElement.find('> div').hide().slideDown 'fast'
                scope.$apply()


          # apply DataTable options, use defaults if none specified by user
          options = {}
          if attrs.dataTable.length > 0
            options = scope.$eval(attrs.dataTable)
          else
            options =
              bStateSave:      true
              iCookieDuration: 2419200 # 1 month
              bJQueryUI:       false
              bPaginate:       false
              bLengthChange:   false
              bFilter:         false
              bInfo:           false
              bDestroy:        true

          # Tell the dataTables plugin what columns to use
          # We can either derive them from the dom, or use setup from the controller
          explicitColumns = []
          element.find("th").each (index, elem) ->
            explicitColumns.push $(elem).text()

          if explicitColumns.length > 0
            options["aoColumns"] = explicitColumns
          else
            if attrs.aoColumns
              options["aoColumns"] = scope.$eval(attrs.aoColumns)


          # aoColumnDefs is dataTables way of providing fine control over column config
          if attrs.aoColumnDefs
            options["aoColumnDefs"] = scope.$eval(attrs.aoColumnDefs)

          if attrs.fnRowCallback
            options["fnRowCallback"] = scope.$eval(attrs.fnRowCallback)
          else
            options["fnRowCallback"] = () ->


          if attrs.aaSorting
            options['aaSorting'] = scope.$eval(attrs.aaSorting)


          if options
            options['fnCreatedRow'] = (nRow, aData, iDataIndex) ->
              return


          options['fnDrawCallback'] = (data) ->
            bindDetailCallbacks()
            $compile($(data.nTable).find('tbody'))(scope)
            if !scope.$$phase
              scope.$apply()


          # apply the plugin
          dataTable  = element.dataTable(options)
          if attrs.aaData
            keysLength = scope.getKeysLength(attrs.aaData)
          else
            keysLength = 0

          # This method of updating is used for server-side data tables
          if options.bServerSide && attrs.updateOnResourcePost
            scope.$on 'resourcePost', (e, data) ->
              if data['resourceName'] == attrs.updateOnResourcePost
                dataTable.fnDraw() #Will call fnServerData()
            scope.$on 'resourcePut', (e, data) ->
              if data['resourceName'] == attrs.updateOnResourcePost
                dataTable.fnDraw() #Will call fnServerData()

          if options.bServerSide && attrs.updateWatch
            scope.$watch attrs.updateWatch, () ->
              dataTable.fnDraw()
            , true

          # watch for any changes to our data, rebuild the DataTable
          scope.$watch attrs.aaData, (value, oldValue) ->
            if keysLength == scope.getKeysLength(value)
              return
            keysLength = scope.getKeysLength(value)
            val = value or null
            if val
              convertedVal = []
              for propName, propVal of val
                if !propVal.deletedAt
                  convertedVal.push propVal
              dataTable.fnClearTable()
              dataTable.fnAddData convertedVal
          , true


define [
  'jquery'
  'angular'
  'angular-ui'
  'underscore'
  'underscore_string'
  'utils/utilBuildDTQuery'

  'controllers/widgets/widgetExerciseBuilder/groupFieldAddFormControllers/controllerWidgetExerciseBuilderGroupFieldOpenResponse'
  'controllers/widgets/widgetExerciseBuilder/groupFieldAddFormControllers/controllerWidgetExerciseBuilderGroupFieldSelectIndividual'
  'controllers/widgets/widgetExerciseBuilder/groupFieldAddFormControllers/controllerWidgetExerciseBuilderGroupFieldSelectMultiple'
  'controllers/widgets/widgetExerciseBuilder/groupFieldAddFormControllers/controllerWidgetExerciseBuilderGroupFieldYesNo'
  'controllers/widgets/widgetExerciseBuilder/groupFieldAddFormControllers/controllerWidgetExerciseBuilderGroupFieldPercentageSlider'

  'controllers/widgets/widgetExerciseBuilder/groupFieldManageControllers/controllerWidgetExerciseBuilderFieldManageOpenResponse'
  'controllers/widgets/widgetExerciseBuilder/groupFieldManageControllers/controllerWidgetExerciseBuilderFieldManageSelectIndividual'
  'controllers/widgets/widgetExerciseBuilder/groupFieldManageControllers/controllerWidgetExerciseBuilderFieldManageSelectMultiple'
  'controllers/widgets/widgetExerciseBuilder/groupFieldManageControllers/controllerWidgetExerciseBuilderFieldManageYesNo'
  'controllers/widgets/widgetExerciseBuilder/groupFieldManageControllers/controllerWidgetExerciseBuilderFieldManageSlider'

  'controllers/widgets/widgetExerciseBuilder/controllerWidgetExerciseBuilderGroupEdit'


  'text!views/widgetExerciseBuilder/viewWidgetExerciseBuilder.html'

  'text!views/widgetExerciseBuilder/fields/viewPartialExerciseBuilderFieldOpenResponse.html'
  'text!views/widgetExerciseBuilder/fields/viewPartialExerciseBuilderFieldSelectIndividual.html'
  'text!views/widgetExerciseBuilder/fields/viewPartialExerciseBuilderFieldSlider.html'
  'text!views/widgetExerciseBuilder/fields/viewWidgetExerciseBuilderFieldButtons.html'

  'text!views/widgetExerciseBuilder/viewWidgetExerciseBuilderDetailsEJS.html'
  'text!views/widgetExerciseBuilder/viewWidgetExerciseBuilderTemplateListButtonsEJS.html'
  'text!views/widgetExerciseBuilder/viewWidgetExerciseBuilderArchivedTemplateListButtonsEJS.html'
  'text!views/widgetExerciseBuilder/viewPartialExerciseBuilderNewTemplateForm.html'
  'text!views/widgetExerciseBuilder/viewPartialExerciseBuilderNewGroupForm.html'
  'text!views/widgetExerciseBuilder/viewPartialExerciseBuilderGroupMenu.html'
  'text!views/widgetExerciseBuilder/formPartials/viewPartialExerciseBuilderGroupFieldOpenResponse.html'
  'text!views/widgetExerciseBuilder/formPartials/viewPartialExerciseBuilderGroupFieldSelectIndividual.html'
  'text!views/widgetExerciseBuilder/formPartials/viewPartialExerciseBuilderGroupFieldPercentageSlider.html'
  'ejs'
  'async'
], (
  $
  angular
  angularUi
  _
  _string
  utilBuildDTQuery

  #Field add controllers
  ControllerWidgetExerciseBuilderGroupFieldOpenResponse
  ControllerWidgetExerciseBuilderGroupFieldSelectIndividual
  ControllerWidgetExerciseBuilderGroupFieldSelectMultiple
  ControllerWidgetExerciseBuilderGroupFieldYesNo
  ControllerWidgetExerciseBuilderGroupFieldPercentageSlider

  #Field manage controllers
  ControllerWidgetExerciseBuilderFieldManageOpenResponse
  ControllerWidgetExerciseBuilderFieldManageSelectIndividual
  ControllerWidgetExerciseBuilderFieldManageSelectMultiple
  ControllerWidgetExerciseBuilderFieldManageYesNo
  ControllerWidgetExerciseBuilderFieldManageSlider

  ControllerWidgetExerciseBuilderGroupEdit



  viewWidgetExerciseBuilder

  viewPartialExerciseBuilderFieldOpenResponse
  viewPartialExerciseBuilderFieldSelectIndividual
  viewPartialExerciseBuilderFieldSlider
  viewWidgetExerciseBuilderFieldButtons

  viewWidgetExerciseBuilderDetailsEJS
  viewWidgetExerciseBuilderTemplateListButtonsEJS
  viewWidgetExerciseBuilderArchivedTemplateListButtonsEJS
  viewPartialExerciseBuilderNewTemplateForm
  viewPartialExerciseBuilderNewGroupForm
  viewPartialExerciseBuilderGroupMenu
  viewPartialExerciseBuilderGroupFieldOpenResponse
  viewPartialExerciseBuilderGroupFieldSelectIndividual
  viewPartialExerciseBuilderGroupFieldPercentageSlider

  EJS
  async
) ->
  (Module) ->

    Module.run ['$templateCache',
      ($templateCache) ->
        #main Template
        $templateCache.put 'viewWidgetExerciseBuilder', viewWidgetExerciseBuilder

        #Field Templates
        $templateCache.put 'viewPartialExerciseBuilderFieldOpenResponse',     viewPartialExerciseBuilderFieldOpenResponse
        $templateCache.put 'viewPartialExerciseBuilderFieldSelectIndividual', viewPartialExerciseBuilderFieldSelectIndividual
        $templateCache.put 'viewPartialExerciseBuilderFieldSlider',           viewPartialExerciseBuilderFieldSlider
        $templateCache.put 'viewWidgetExerciseBuilderFieldButtons',           viewWidgetExerciseBuilderFieldButtons

        #Partials
        $templateCache.put 'viewPartialExerciseBuilderNewTemplateForm', viewPartialExerciseBuilderNewTemplateForm
        $templateCache.put 'viewPartialExerciseBuilderNewGroupForm',    viewPartialExerciseBuilderNewGroupForm
        $templateCache.put 'viewPartialExerciseBuilderGroupMenu',       viewPartialExerciseBuilderGroupMenu

        #Partials -- field adds
        $templateCache.put 'viewPartialExerciseBuilderGroupFieldOpenResponse',     viewPartialExerciseBuilderGroupFieldOpenResponse
        $templateCache.put 'viewPartialExerciseBuilderGroupFieldSelectIndividual', viewPartialExerciseBuilderGroupFieldSelectIndividual
        $templateCache.put 'viewPartialExerciseBuilderGroupFieldPercentageSlider', viewPartialExerciseBuilderGroupFieldPercentageSlider
    ]


    helperReorderGroupOrdinals = ($scope, apiRequest, groupsHash, insertOrdinalNum, insertUid = false, topCallback) ->
      groupsArray = $scope.getArrayFromHash groupsHash

      groupsArray = _.sortBy groupsArray, (item) ->
        return item.ordinal

      groupsArray = _.filter groupsArray, (item) ->
        !item.deletedAt

      #Now sorted by ordinal
      i = 0
      groupsArray = _.map groupsArray, (item) ->

        if insertUid
          if item.uid == insertUid
            return item #This one is about to be tweaked

        if i >= insertOrdinalNum
          item.ordinal = i + 1
        else
          item.ordinal = i
        i++
        return item

      async.map groupsArray, (item, callback) ->

        apiRequest.put 'group', item.uid, {
          ordinal: item.ordinal
        }, {}, (result) ->
          callback()

      , (err, results) ->

        topCallback()




    #Add Field Form Controllers
    ControllerWidgetExerciseBuilderGroupFieldOpenResponse     Module
    ControllerWidgetExerciseBuilderGroupFieldSelectIndividual Module
    ControllerWidgetExerciseBuilderGroupFieldSelectMultiple   Module
    ControllerWidgetExerciseBuilderGroupFieldYesNo            Module
    ControllerWidgetExerciseBuilderGroupFieldPercentageSlider Module


    ControllerWidgetExerciseBuilderFieldManageOpenResponse     Module
    ControllerWidgetExerciseBuilderFieldManageSelectIndividual Module
    ControllerWidgetExerciseBuilderFieldManageSelectMultiple   Module 
    ControllerWidgetExerciseBuilderFieldManageYesNo            Module
    ControllerWidgetExerciseBuilderFieldManageSlider           Module


    ControllerWidgetExerciseBuilderGroupEdit                   Module


    ###
    #
    #  PRIMARY CONTROLLER
    #
    ###
    Module.controller 'ControllerWidgetExerciseBuilder', ['$scope', '$route', '$routeParams', '$templateCache', 'socket', 'apiRequest', '$dialog',
      ($scope, $route, $routeParams, $templateCache, socket, apiRequest, $dialog) ->


        $scope.viewModel =

          toggleTemplatesListCollapsed: () ->
            options = {}
            options.direction = 'left'
            if !$scope.viewModel.templatesListCollapsed
              $('#templatesListPortlet').effect 'blind', {direction:'left'}, () ->

                setTimeout () ->
                  $scope.viewModel.templatesListCollapsed = !$scope.viewModel.templatesListCollapsed
                  if !$scope.$$phase
                    $scope.$apply()
                , 150

            else
              $scope.viewModel.templatesListCollapsed = !$scope.viewModel.templatesListCollapsed


          showAddNewTemplate:      false
          showAddNewTemplateGroup: false

          routeParams: {}
          templates:   {}

          newTemplateForm:      {}
          newTemplateGroupForm: {}
          editTemplateNameForm: {}










          archivedListLength:    0
          nonArchivedListLength: 0


          restoreTemplate: (uid) ->
            apiRequest.put 'template', uid, {
              deletedAt: null
            }, {}, (response) ->
              console.log response



          archivedTemplatesListDataTable:
            columnDefs: [
              mData:     null
              aTargets:  [0]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml  = '<a href="#' + $scope.viewRoot + '/' + $scope.escapeHtml(full.uid) + '">'
                if full.name
                  resHtml += '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].name">' + $scope.escapeHtml(full.name) + '</span>'
                resHtml += '</a>'
                return resHtml        
            ,
              mData:     null
              aTargets:  [1]
              bSortable: true
              mRender: (data, type, full) ->
                '{{ resourcePool[\'' + full.employeeUid + '\'].firstName }} {{ resourcePool[\'' + full.employeeUid + '\'].lastName }}'
            ,
              mData:     null
              aTargets:  [2]
              bSortable: true
              sWidth:    '125px'
              mRender: (data, type, full) ->              
                '{{ resourcePool[\'' + full.uid + '\'].createdAt | date:\'short\' }}'
            ,
              mData:     null
              aTargets:  [3]
              bSortable: true
              sWidth:    '75px'
              mRender: (data, type, full) ->
                '<span data-ng-show = "resourcePool[\'' + full.uid + '\'].revisions[0].finalized">Yes</span>
                 <span data-ng-show = "!resourcePool[\'' + full.uid + '\'].revisions[0].finalized">No</span>'
            ,
              mData:     null
              aTargets:  [4]
              bSortable: false
              sWidth:    '100px'
              mRender: (data, type, full) ->
                uid  = $scope.escapeHtml full.uid
#                {{ resourcePool['<%= templateUid %>'].revisions[0].uid }}

                if !_.isUndefined(resourcePool[uid].revisions[0])
                  revisionUid = resourcePool[uid].revisions[0].uid
                else 
                  revisionUid = ''

                html = new EJS({text: viewWidgetExerciseBuilderArchivedTemplateListButtonsEJS}).render({
                  uid: uid
                })

            ]
            options:
              bStateSave:      true
              iCookieDuration: 2419200
              bJQueryUI:       false
              bPaginate:       true
              bLengthChange:   true
              bFilter:         false
              bInfo:           true
              bDestroy:        true
              bServerSide:     true
              bProcessing:     true
              fnServerData: (sSource, aoData, fnCallback, oSettings) ->
                query = utilBuildDTQuery ['name', 'employeeUid', 'createdAt'],
                  ['name', 'employeeUid', 'createdAt'],
                  oSettings

                query.filter.push ['deletedAt', '!=', 'null']
                query.expand = [{
                  resource: 'revisions'
                  expand: [{
                    resource: 'template'
                  },{
                    resource: 'employee'
                  }]
                }]

                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'template', [], query, (response, responseRaw) ->
                  if response.code == 200

                    $scope.viewModel.archivedListLength = response.response.length

                    responseDataString = responseRaw #JSON.stringify(response.response)
                    if cacheResponse == responseDataString
                      return
                    cacheResponse = responseDataString

                    dataArr = _.toArray response.response.data

                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               dataArr












          templatesListDataTable:
            detailRow: (obj) ->
              uid = $scope.escapeHtml obj.uid

              html = new EJS( text: viewWidgetExerciseBuilderDetailsEJS ).render
                templateUid: uid

              #console.log 'html1'
              #console.log html

              return html

            columnDefs: [
              mData:     null
              aTargets:  [0]
              bSortable: true
              mRender: (data, type, full) ->
                resHtml  = '<a href="#' + $scope.viewRoot + '/' + $scope.escapeHtml(full.uid) + '">'
                if full.name
                  resHtml += '<span data-ng-bind="resourcePool[\'' + full.uid + '\'].name">' + $scope.escapeHtml(full.name) + '</span>'
                resHtml += '</a>'
                return resHtml        
            ,
              mData:     null
              aTargets:  [1]
              bSortable: true
              mRender: (data, type, full) ->
                '{{ resourcePool[\'' + full.employeeUid + '\'].firstName }} {{ resourcePool[\'' + full.employeeUid + '\'].lastName }}'
            ,
              mData:     null
              aTargets:  [2]
              bSortable: true
              sWidth:    '125px'
              mRender: (data, type, full) ->              
                '{{ resourcePool[\'' + full.uid + '\'].createdAt | date:\'short\' }}'
            ,
              mData:     null
              aTargets:  [3]
              bSortable: true
              sWidth:    '75px'
              mRender: (data, type, full) ->
                '<span data-ng-show = "resourcePool[\'' + full.uid + '\'].revisions[0].finalized">Yes</span>
                 <span data-ng-show = "!resourcePool[\'' + full.uid + '\'].revisions[0].finalized">No</span>'
            ,
              mData:     null
              aTargets:  [4]
              bSortable: false
              sWidth:    '100px'
              mRender: (data, type, full) ->
                uid  = $scope.escapeHtml full.uid
#                {{ resourcePool['<%= templateUid %>'].revisions[0].uid }}

                if !_.isUndefined(resourcePool[uid].revisions[0])
                  revisionUid = resourcePool[uid].revisions[0].uid
                else 
                  revisionUid = ''

                html = new EJS({text: viewWidgetExerciseBuilderTemplateListButtonsEJS}).render({templateUid: uid, revisionUid: revisionUid})
            ]
            options:
              bStateSave:      true
              iCookieDuration: 2419200
              bJQueryUI:       false
              bPaginate:       true
              bLengthChange:   true
              bFilter:         false
              bInfo:           true
              bDestroy:        true
              bServerSide:     true
              bProcessing:     true
              fnServerData: (sSource, aoData, fnCallback, oSettings) ->
                query = utilBuildDTQuery ['name', 'employeeUid', 'createdAt'],
                  ['name', 'employeeUid', 'createdAt'],
                  oSettings

                query.filter.push ['deletedAt', '=', 'null']
                query.expand = [{
                  resource: 'revisions'
                  expand: [{
                    resource: 'template'
                  },{
                    resource: 'employee'
                  }]
                }]

                cacheResponse   = ''
                oSettings.jqXHR = apiRequest.get 'template', [], query, (response, responseRaw) ->
                  if response.code == 200

                    $scope.viewModel.nonArchivedListLength = response.response.length

                    responseDataString = responseRaw #JSON.stringify(response.response)
                    if cacheResponse == responseDataString
                      return
                    cacheResponse = responseDataString

                    dataArr = _.toArray response.response.data

                    fnCallback
                      iTotalRecords:        response.response.length
                      iTotalDisplayRecords: response.response.length
                      aaData:               dataArr


          deleteConfirmDialogTemplate: (templateUid) ->
            apiRequest.get 'template', [templateUid], {}, (response) ->
              title = 'Delete Dialog'
              msg   = 'Dire Consequences...'
              btns  = [
                result:   false
                label:    'Cancel'
                cssClass: 'red'
              ,
                result:   true
                label:    'Confirm'
                cssClass: 'green'
              ]
              $dialog.messageBox(title, msg, btns).open()
                .then (result) ->
                  if result
                    apiRequest.delete 'template', templateUid, {}, (result) ->
                      return
                      #console.log result

          clearnewTemplateGroupForm: () ->
            $scope.viewModel.showAddNewTemplateGroup = false
            if $scope.newTemplateGroupForm
              $scope.newTemplateGroupForm.$setPristine()
            $scope.viewModel.newTemplateGroupForm = {}

          clearNewTemplateForm: () ->

            $scope.viewModel.showAddNewTemplate    = false
            $scope.viewModel.postNewTemplateSaving = false
            $scope.viewModel.newTemplateForm       = {}
            if $scope.newTemplateForm
              $scope.newTemplateForm.$setPristine()

          postNewTemplateGroup: () ->
            #$groupsObj = $scope.viewModel.currentTemplateRevision.groups
            if !$scope.viewModel.routeParams.revisionUid
              return
            $groupsObj = $scope.resourcePool[$scope.viewModel.routeParams.revisionUid].groups

            helperReorderGroupOrdinals $scope,
              apiRequest,
              $groupsObj,
              0,
              false,
              () ->
                apiRequest.post 'group', {
                  name:        $scope.viewModel.newTemplateGroupForm.name
                  description: $scope.viewModel.newTemplateGroupForm.description
                  ordinal:     0
                  revisionUid: $scope.viewModel.routeParams.revisionUid
                }, {}, (result) ->
                  $scope.viewModel.clearnewTemplateGroupForm()
                  console.log result


          revisionChangeSummary: ''
          putRevisionChangeSummary: () ->
            apiRequest.put 'revision', [$scope.viewModel.routeParams.revisionUid], {
              changeSummary: $scope.viewModel.revisionChangeSummary
            }, {}, (response) ->
              console.log response


          putRevisionFinalize: () ->
            title = 'Save Revision'
            msg   = 'Save this exercise revision if you\'re done editing. You will not be able to make changes to this revision after your save.'
            btns  = [
              result:   false
              label:    'Cancel'
              cssClass: 'red'
            ,
              result:   true
              label:    'Confirm'
              cssClass: 'green'
            ]
            $dialog.messageBox(title, msg, btns).open()
              .then (result) ->
                if result
                  apiRequest.put 'revision', [$scope.viewModel.routeParams.revisionUid], {
                    finalized: true
                  }, {}, (response) ->
                    console.log response


          putTemplate: (templateUid) ->
            apiRequest.put 'template', [templateUid], {
              name: $scope.viewModel.formEditTemplateName.name
            }, {}, (response) ->
              console.log response
              $scope.viewModel.showEditTemplateName      = false
              #$scope.viewModel.formEditTemplateName.name = $scope.viewModel.currentTemplate.name



          postNewTemplate: () ->

            $scope.viewModel.postNewTemplateSaving = true

            apiRequest.post 'template', {
              name:         $scope.viewModel.newTemplateForm.name
              type:         $scope.viewModel.newTemplateForm.type
            }, {}, (response) ->
              
              if response.code != 201
                return

              uid  = response.uids[0]
              hash = window.location.hash

              apiRequest.get 'template', [uid + ''], {
                expand: [{
                  resource: 'revisions'
                }]
              }, (templateResponse) ->              

                if templateResponse.code != 200
                  return
                
                $scope.viewModel.clearNewTemplateForm()

                window.location.hash = hash + '/' + templateResponse.response.data.revisions[0].uid



              ###
              MODIFIED API TO IMPLICITLY CREATE FIRST REVISION AND GROUP

              #Create first revision
              apiRequest.post 'revision', {
                changeSummary: ''
                scope:         ''
                templateUid:   result.uids[0]
              }, {}, (result) ->
                console.log result
                $scope.viewModel.clearNewTemplateForm()
              #console.log result
              ###

          currentTemplateRevision: {}



          ###
          fetchCurrentTemplateRevision: () ->

            if !$scope.viewModel.routeParams.templateUid
              $scope.viewModel.currentTemplateRevision = false
              return
            if !$scope.viewModel.templates
              return
            if !$scope.viewModel.routeParams.templateUid
              return
            return

            $scope.resourcePool[$scope.viewModel.routeParams.templateUid]

            apiRequest.get 'revision', [], {}, (response) ->

            template = $scope.viewModel.templates[$scope.viewModel.routeParams.templateUid]
            $scope.viewModel.currentTemplateRevision = $scope.getLastObjectFromHash template.revisions
            #console.log $scope.viewModel.currentTemplateRevision
          ###


          currentTemplate: false
          fetchCurrentTemplate: () ->

            if !$scope.viewModel.routeParams.revisionUid
              $scope.viewModel.currentTemplate = false
              return
            apiRequest.get 'revision', [$scope.viewModel.routeParams.revisionUid], {
              expand: [{
                resource: 'template',                
              },{
                resource: 'groups',
                expand:   [{
                  resource: 'fields'
                }]
              }]
            }, (response) ->

              if response.code != 200
                return

              $scope.viewModel.currentTemplate = response.response.template 
              $scope.viewModel.currentRevision = response.response             


        $scope.fieldsSortableOptions =
          connectWith: 'div[data-ui-sortable]'
          disabled: false
          update: () ->

            $('div[data-group-uid]').each () ->

              groupUid          = $(this).attr('data-group-uid')
              groupFieldOrdinal = 0

              $(this).find('div[data-field-uid]').each () ->

                fieldUid = $(this).attr('data-field-uid')
                field    = $scope.resourcePool[fieldUid]

                if (field.ordinal == groupFieldOrdinal) and (field.groupUid == groupUid)
                  #Nothing has changed here
                  groupFieldOrdinal++
                  return

                if field.groupUid != groupUid
                  $scope.resourcePool[groupUid].fields[field.uid] = field
                  delete $scope.resourcePool[field.groupUid].fields[field.uid]
                  field.groupUid = groupUid

                apiRequest.put 'field', fieldUid, {
                  ordinal:  groupFieldOrdinal
                  groupUid: groupUid
                }, {}, (result) ->
                  console.log result

                #delete $scope.resourcePool[fieldUid]
                groupFieldOrdinal++


        #Hack to update children, with rate limiting for performance
        rateLimit = null
        $scope.$on 'resourcePut', (e, data) ->

          if !$scope.routeParams.revisionUid
            return

          groupUids = []

          found = false
          for groupUid, group of $scope.resourcePool[$scope.routeParams.revisionUid].groups
            groupUids.push groupUid
            for fieldUid, field of group.fields
              if fieldUid == data['uid']
                found = true
                break

          if found
            clearTimeout rateLimit
            rateLimit = setTimeout () ->
              apiRequest.get 'group', groupUids, {expand: [{resource: 'fields'}]}, (response) ->
                console.log 'GET groups.fields'
                console.log response
            , 100



        hashChangeUpdate = () ->
          $scope.viewModel.showEditTemplateName = false
          $scope.viewModel.routeParams          = $routeParams
          if $routeParams.revisionUid
            $scope.viewModel.fetchCurrentTemplate()


        $scope.$on '$routeChangeSuccess', () ->
          hashChangeUpdate()

        hashChangeUpdate()
        $scope.viewModel.fetchCurrentTemplate()

    ]




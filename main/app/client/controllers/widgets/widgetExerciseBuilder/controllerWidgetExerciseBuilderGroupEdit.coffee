define [
  'underscore'
], (
  _
) -> 

  (Module) ->

    Module.controller 'ControllerWidgetExerciseBuilderGroupEdit', ['$scope', '$routeParams', 'apiRequest', '$dialog',
      ($scope, $routeParams, apiRequest, $dialog) ->

        fieldTypes = [
          'OpenResponse'
          'SelectIndividual'
          'SelectMultiple'
          'YesNo'
          'PercentageSlider'
        ]

        $scope.viewModel =
          showAddNewField_OpenType: ''

          cancelAddNewField: () ->
            for type in fieldTypes
              $scope.viewModel.showAddNewField_OpenType = ''

          moveGroup: (dir) ->
            newOrdinal   = $scope.group.ordinal

            if !$routeParams.revisionUid
              return

            groupsLength = _.filter(_.toArray($scope.resourcePool[$routeParams.revisionUid].groups), (item) -> !item.deletedAt).length

            if dir == 'down'
              newOrdinal++
            else
              newOrdinal--

            if newOrdinal < 0
              return
            if (newOrdinal + 1) > groupsLength
              return

            _$scope = $scope
            helperReorderGroupOrdinals $scope,
              apiRequest,
              $scope.resourcePool[$routeParams.revisionUid].groups,
              newOrdinal,
              $scope.group.uid,
              () ->
                apiRequest.put 'group', [$scope.group.uid], {
                  ordinal: newOrdinal
                }, {}, (response) ->
                  console.log response


          deleteGroup: (groupUid) ->

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
                  apiRequest.delete 'group', [groupUid], {}, (result) ->
                    #console.log result

                    helperReorderGroupOrdinals $scope,
                      apiRequest,
                      $scope.resourcePool[$routeParams.revisionUid].groups,
                      _.toArray($scope.resourcePool[$routeParams.revisionUid].groups).length,
                      false,
                      () ->
                        console.log 'groups reindexed'

          putGroup: (groupUid) ->
            console.log 'groupUid'
            console.log groupUid

            name = $scope.resourcePool[groupUid].name

            if (name.length < $scope.clientOrmShare.group.model.name.validate.len[0]) || (name.length > $scope.clientOrmShare.group.model.name.validate.len[1])

              title = 'Invalid name'
              msg   = 'Group name length must be between ' + $scope.clientOrmShare.group.model.name.validate.len[0] + ' and ' + $scope.clientOrmShare.group.model.name.validate.len[1] + ' characters'
              btns  = [
                result:   'cancel'
                label:    'Cancel'
                cssClass: 'red'
              ,
                result:   'ok'
                label:    'OK'
                cssClass: 'green'
              ]

              $dialog.messageBox(title, msg, btns)
                .open()
                .then (result) ->
                  if result == 'cancel'
                    apiRequest.get 'group', [groupUid], {}, () ->
                      $scope.nameEditing = false

              return true

            else

              apiRequest.put 'group', groupUid, {
                name: $scope.resourcePool[groupUid].name
              }, {}, (response) ->
                console.log response
              return false
    ]
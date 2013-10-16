define [], () ->

  ($routeProvider) ->

    $routeProvider.when '/profile',
      root: '/profile'
      group: 'profile'
      subGroup: ''
      widgetViews: [
      ]

    $routeProvider.when '/admin/themis',
      root: '/admin/themis'
      group: 'dashboard'
      subGroup: ''
      widgetViews: [
      #  ['viewWidgetActivityFeed', 'viewWidgetActivityFeed']
        [
          name: 'viewWidgetBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetActivityFeed'
          data: {}
        ]
        #['viewWidgetActivityExercisesQuizes', 'viewWidgetScheduler']
        #['viewWidgetQuarterlyTestingReport']
      ]




    $routeProvider.when '/admin/themis/templates',
      root: '/admin/themis/templates'
      group: 'templatesExercises'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetExerciseBuilder'
          data: {}
        ]
      ]
    $routeProvider.when '/admin/themis/templates/:revisionUid',
      root: '/admin/themis/templates'
      group: 'templatesExercises'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetExerciseBuilder'
          data: {}
        ]
      ]

    ###
    $routeProvider.when '/admin/themis/templates/:templateUid/:revisionUid',
      root: '/admin/themis/templates'
      group: 'templatesExercises'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetExerciseBuilder'
          data: {}
        ]
      ]
    ###


    ###
    $routeProvider.when '/admin/themis/templates/mini',
      root: '/admin/themis/templates/mini'
      group: 'templatesQuizes'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetExerciseBuilder'
          data: {}
        ]
      ]
    $routeProvider.when '/admin/themis/templates/mini/:templateUid',
      root: '/admin/themis/templates/mini'
      group: 'templatesQuizes'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetExerciseBuilder'
          data: {}
        ]
      ]
    $routeProvider.when '/admin/themis/templates/mini/:templateUid/:revisionUid',
      root: '/admin/themis/templates/mini'
      group: 'templatesQuizes'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetExerciseBuilder'
          data: {}
        ]
      ]
    ###


    $routeProvider.when '/admin/themis/exercises',
      root: '/admin/themis/exercises'
      group: 'exercises'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetScheduler'
          data: {}
        ]
      ]
    $routeProvider.when '/admin/themis/exercises/:eventUid',
      root: '/admin/themis/exercises'
      group: 'exercises'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetScheduler'
          data: {}
        ]
      ]







    $routeProvider.when '/admin/themis/settings',
      root:     '/admin/themis/settings'
      group:    'settings'
      subGroup: ''
      widgetViews: [
      ]





    $routeProvider.when '/admin/themis/settings/dictionaries',
      root:     '/admin/themis/settings/dictionaries'
      group:    'settingsDictionaries'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetDictionaryManager'
          data: {}
        ]
      ]
    $routeProvider.when '/admin/themis/settings/dictionaries/:dictionaryUid',
      root:     '/admin/themis/settings/dictionaries'
      group:    'settingsDictionaries'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetDictionaryManager'
          data: {}
        ]
      ]


    $routeProvider.when '/admin/themis/settings/employees',
      root:     '/admin/themis/settings/employees'
      group:    'settingsEmployees'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetEmployeeManager'
          data:  {}
        ]
      ]
    $routeProvider.when '/admin/themis/settings/employees/:employeeUid',
      root:     '/admin/themis/settings/employees'
      group:    'settingsEmployees'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetEmployeeManager'
          data:  {}
        ]
      ]




    ###
    $routeProvider.when '/quizzes',
      root: '/quizzes'
      group: 'quizSubmit'
      subGroup: ''
      widgetViews: [
      #  ['viewWidgetScheduler']
      ]
    $routeProvider.when '/quizzes/:eventParticipantUid',
      root: '/quizzes'
      group: 'quizSubmit'
      subGroup: ''
      widgetViews: [
        ['viewNoBreadCrumbs']
        ['viewWidgetQuizExerciseSubmitter']
      ]
    ###


    $routeProvider.when '/exercises',
      root:     '/exercises'
      group:    'exerciseSubmit'
      subGroup: ''
      widgetViews: [
      #  ['viewWidgetScheduler']
      ]
    $routeProvider.when '/exercises/:eventParticipantUid',
      root:     '/exercises'
      group:    'exerciseSubmit'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
          name: 'viewWidgetQuizExerciseSubmitter'
          data: {}
        ]
      ]


    ###
    $routeProvider.when '/admin/themis/reports/timeline',
      root: '/admin/themis/reports/timeline'
      group: 'reportsTimeline'
      subGroup: ''
      widgetViews: [
        [
          name: 'viewNoBreadCrumbs'
          data: {}
        ]
        [
        #  name: 'viewWidgetTimeline'
        #  data: {}
        #,
        #  name: 'viewWidgetScheduler'
        #  data: {}
        #,
          name: 'viewWidgetTabs'
          data:
            tabs: [
              name:       'Calendar'
              widgetName: 'viewWidgetScheduler'
              data:       {}
            ,
              name:       'Timeline'
              widgetName: 'viewWidgetTimeline'
              data:       {}
            ]
        ]
      ]

      widgetData:
        widgetTimeline:  {}
        widgetScheduler: {}
        widgetTabs:
          tabs: [
            title: 'Summary'
            view:  'viewWidgetTimeline'
          ,
            title: 'Calendar'
            view:  'viewWidgetScheduler'
          ]

    ###


    $routeProvider.otherwise
      invalid: true





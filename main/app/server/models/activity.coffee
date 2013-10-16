# dictionary model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:   SEQ.INTEGER
    type: SEQ.ENUM [
      'createRevision'
      'createDictionary'
      'createEmployee'
      'createEmployeeBulk'
      'createEvent'
      'editEvent'
      'viewQuizExercise'
      'completeQuizExercise'
      'eventInitialized'
    ]

    #Optional stuff each may have
    templateUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: false
    revisionUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: false
    dictionaryUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: false
    dictionaryItemUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: false
    employeeUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: false
    eventUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: false



    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'template'
  ,
    relation: 'belongsTo'
    model: 'revision'
  ,
    relation: 'belongsTo'
    model: 'dictionary'
  ,
    relation: 'belongsTo'
    model: 'dictionaryItem'
  ,
    relation: 'belongsTo'
    model: 'event'
  ,
    relation: 'belongsTo'
    model: 'employee'
  ]
  options:
    paranoid: true

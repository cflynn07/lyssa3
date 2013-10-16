# event model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:       SEQ.INTEGER

    initialViewDateTime:
      type: SEQ.DATE
      validate:
        notNull: false

    finalizedDateTime:
      type: SEQ.DATE
      validate:
        notNull: false

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    employeeUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    eventUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [
    relation: 'hasMany'
    model: 'submissionField'
  ,
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'employee'
  ,
    relation: 'belongsTo'
    model: 'event'
  ]
  options:
    paranoid: true

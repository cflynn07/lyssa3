# event model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:       SEQ.INTEGER
    name:
      type:   SEQ.STRING
      validate:
      #  isAlphanumeric: true
        len: [5, 50]
    dateTime: SEQ.DATE


    cronDaemonUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true


    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    revisionUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    employeeUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'employee'
  ,
    relation: 'belongsTo'
    model: 'revision'
  ,
    relation: 'hasMany'
    model: 'eventParticipant'
  ]
  options:
    paranoid: true

# revision model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:            SEQ.INTEGER
    changeSummary: SEQ.TEXT
    scope:         SEQ.TEXT
    finalized:     SEQ.BOOLEAN

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true
    templateUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true
    employeeUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    deletedAt: SEQ.DATE

  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'template'
  ,
    relation: 'belongsTo'
    model: 'employee'
  ,
    relation: 'hasMany'
    model: 'group'
  ]
  options:
    paranoid: true

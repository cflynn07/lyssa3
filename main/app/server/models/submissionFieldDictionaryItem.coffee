# submissionField model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:   SEQ.INTEGER

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    submissionFieldUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    dictionaryItemUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [

    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'submissionField'
  ,
    relation: 'belongsTo'
    model: 'dictionaryItem'

  ]
  options:
    paranoid: true

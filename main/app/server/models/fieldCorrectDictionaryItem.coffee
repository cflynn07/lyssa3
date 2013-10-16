config = require '../config/config'
orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:      SEQ.INTEGER

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true
    dictionaryItemUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
    fieldUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true


  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'dictionaryItem'
  ,
    relation: 'belongsTo'
    model: 'field'
  ]

  options:
    paranoid: true

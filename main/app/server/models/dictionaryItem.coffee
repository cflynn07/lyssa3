# dictionary model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:   SEQ.INTEGER
    name:
      type: SEQ.STRING
      validate:
        len: [2, 100]

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true
    dictionaryUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'dictionary'
  ,
    relation: 'hasMany'
    model: 'fieldCorrectDictionaryItem'
  ]
  options:
    paranoid: true

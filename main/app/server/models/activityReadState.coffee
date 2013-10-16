# dictionary model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:   SEQ.INTEGER
    name:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [
#    relation: 'belongsTo'
#    model: 'client'
#  ,
#    relation: 'hasMany'
#    model: 'dictionaryItem'
  ]
  options:
    paranoid: true

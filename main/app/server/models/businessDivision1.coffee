# employee model

config = require '../config/config'
orm    = require GLOBAL.appRoot + 'components/oRM'
SEQ    = orm.SEQ

module.exports =
  model:
    id: SEQ.INTEGER

    name:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [1, 100]

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
    model: 'businessDivision0'
  ]
  options:
    paranoid: true

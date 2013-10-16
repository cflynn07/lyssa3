# field model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:      SEQ.INTEGER

    name:
      type: SEQ.STRING
      validate:
        len: [2, 50]

    description:
      type: SEQ.TEXT

    ordinal: SEQ.INTEGER

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

  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'revision'
  ,
    relation: 'hasMany'
    model: 'field'
  ]
  options:
    paranoid: true

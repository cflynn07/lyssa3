# field model

config = require '../config/config'
orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:      SEQ.INTEGER
    name:
      type:  SEQ.STRING
      validate:
        len: [5, 50]
    type:    SEQ.ENUM config.fieldTypes
    ordinal: SEQ.INTEGER

    multiSelectCorrectRequirement:
      type: SEQ.ENUM [
        'all'
        'any'
      ]
      defaultValue: 'any'

    percentageSliderLeft:
      type: SEQ.STRING
      validate:
        len: [1, 100]

    percentageSliderRight:
      type: SEQ.STRING
      validate:
        len: [1, 100]

    openResponseMinLength:
      type: SEQ.INTEGER
      validate:
        notNull: false

    openResponseMaxLength:
      type: SEQ.INTEGER
      validate:
        notNull: false

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true
    groupUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true
    dictionaryUid:
      type: SEQ.STRING
      validate:
        isUUID: 4

  relations: [
    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'group'
  ,
    relation: 'belongsTo'
    model: 'dictionary'
  ,
    relation: 'hasMany'
    model: 'fieldCorrectDictionaryItem'
  ]
  options:
    paranoid: true

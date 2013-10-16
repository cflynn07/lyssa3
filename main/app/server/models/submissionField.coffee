# submissionField model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:   SEQ.INTEGER

    openResponseValue: SEQ.STRING
    sliderValue:       SEQ.INTEGER
    yesNoValue:        SEQ.BOOLEAN

    clientUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    fieldUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

    eventParticipantUid:
      type: SEQ.STRING
      validate:
        isUUID: 4
        notNull: true

  relations: [

    relation: 'belongsTo'
    model: 'client'
  ,
    relation: 'belongsTo'
    model: 'field'
  ,
    relation: 'belongsTo'
    model: 'eventParticipant'
  ,
    relation: 'hasMany'
    model: 'submissionFieldDictionaryItem'

  ]
  options:
    paranoid: true

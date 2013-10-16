# client model

orm = require GLOBAL.appRoot + 'components/oRM'
SEQ = orm.SEQ

module.exports =
  model:
    id:            SEQ.INTEGER
    name:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    identifier:
      type:        SEQ.STRING
      unique:      true
    address1:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    address2:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [0, 100]
    address3:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [0, 100]
    city:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    stateProvince:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    country:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    telephone:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]
    fax:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [5, 100]




    businessDivision0Name:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [3, 100]

    businessDivision1Name:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [3, 100]

    businessDivision2Name:
      type: SEQ.STRING
      validate:
        isAlphanumeric: true
        len: [3, 100]




  relations: [
    relation: 'hasMany'
    model: 'employee'
  ,
    relation: 'hasMany'
    model: 'dictionary'
  ,
    relation: 'hasMany'
    model: 'dictionaryItem'
  ,
    relation: 'hasMany'
    model: 'event'
  ,
    relation: 'hasMany'
    model: 'eventParticipant'
  ,
    relation: 'hasMany'
    model: 'submissionField'
  ,
    relation: 'hasMany'
    model: 'template'
  ,
    relation: 'hasMany'
    model: 'revision'
  ,
    relation: 'hasMany'
    model: 'group'
  ,
    relation: 'hasMany'
    model: 'field'
  ]
  options:
    paranoid: true

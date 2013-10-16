define [
  'underscore'
], (
  _
) ->


  #DONT USE, this sucks



  (object) ->

    cache = []
    value = JSON.stringify object, (key, value) ->
      console.log 'stacky'
      if _.isObject(value)
        if cache.indexOf(value) > -1
          return
        cache.push value
      return value

    cache = null
    return value



define [
  'underscore'
], (
  _
) ->

  #https://github.com/angular/angular.js/issues/1286
  (Module) ->

    Module.filter 'tel', () ->
      (tel) ->

        value = tel.toString().trim().replace /^\+/, ''
        if value.match /[^0-9]/
          return tel

        switch value.length
          when 10
            country = 1
            city    = value.slice 0, 3
            number  = value.slice 3
          when 11
            country = value[0]
            city    = value.slice 3, 5
            number  = value.slice 4
          when 12
            country = value.slice 0, 3
            city    = value.slice 3, 5
            number  = value.slice 5
          else
            return tel

        if country == 1
          country = ''

        number = number.slice(0, 3) + '-' + number.slice(3)
        return (country + ' (' + city + ') ' +number).trim()

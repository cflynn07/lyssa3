#http://stackoverflow.com/questions/2897478/get-client-timezone-not-gmt-offset-amount-in-js

define [
], (
) ->

  () ->

    now = new Date().toString()
    TZ  = if now.indexOf('(') > -1 then now.match(/\([^\)]+\)/)[0].match(/[A-Z]/g).join('') else now.match(/[A-Z]{3,4}/)[0]
    if TZ == 'GMT' &&  /(GMT\W*\d{4})/.test(now)
      TZ = RegExp.$1
    return TZ

define [
  'jquery'
  'soundmanager2'
], (
  $
  soundManager
) ->

  windowHasFocus = true
  
  $(window).bind 'blur', () ->
    windowHasFocus = false
    #console.log windowHasFocus

  $(window).bind 'focus', () ->
    windowHasFocus = true
    #console.log windowHasFocus

  #Temp Stub
  sounds =
    alert:
      play: () ->


  soundManager.url = window.location.protocol + '//' + window.location.host + '/assets/soundmanager2/soundmanager2.swf'
  soundManager.beginDelayedInit()
  soundManager.onready () ->
    sounds.alert = soundManager.createSound({
      id:       'alertSound'
      url:      window.location.protocol + '//' + window.location.host + '/assets/gentleRoll.mp3'
      volume:   '50'
      autoPlay: false
    })

  return sounds

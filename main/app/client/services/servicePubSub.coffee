define [
  'pubsub'
], (
  PubSub
) ->

  (Module) ->
    Module.factory 'pubsub', () ->
      PubSub

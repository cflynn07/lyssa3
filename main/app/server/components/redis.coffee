redis      = require 'redis'
express    = require 'express.io'
redisStore = require('connect-redis')(express)
config     = require GLOBAL.appRoot + 'config/config'

createClient = () ->
  client = redis.createClient config.redis.port, config.redis.host
  client.auth config.redis.pass, ->
  return client

createStore = () ->
  store = new redisStore config.redis

module.exports =
  createClient: createClient
  createStore:  createStore

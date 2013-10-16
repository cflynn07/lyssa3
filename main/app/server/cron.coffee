require('./config/envGlobals')(GLOBAL)

config         = require './config/config'
twilioClient   = require './config/twilioClient'
mandrill       = require './config/mandrill'
redisClient    = require('./config/redis').createClient()
ORM            = require('./components/oRM')
sequelize      = ORM.setup()
schedule       = require 'node-schedule'
_              = require 'underscore'
activityInsert = require config.appRoot + 'server/components/activityInsert'
uuid           = require 'node-uuid'


#Hash of all events stored in memory

express    = require 'express.io'
pub        = require('./config/redis').createClient()
sub        = require('./config/redis').createClient()
store      = require('./config/redis').createClient()
redisStore = require('./config/redis').createStore()

event            = ORM.model 'event'
eventParticipant = ORM.model 'eventParticipant'
employee         = ORM.model 'employee'

cronDaemonUid = uuid.v4()
events        = {}

app = express().http().io()
app.io.set 'store',
  new express.io.RedisStore
    redis:       require 'redis'
    redisPub:    pub
    redisSub:    sub
    redisClient: store

redisClient.subscribe 'eventCronChannel', () ->
redisClient.on 'message', (channel, message) ->
  if channel == 'eventCronChannel'

    event.find(
      where:
        uid: message
    ).success (resultEvent) ->

      #Don't do anything if we can't find it
      if !resultEvent
        return

      #Cancel it if it already exists, this is most likely the user UPDATING the event
      if !_.isUndefined(events[resultEvent.uid]) && _.isFunction(events[resultEvent.uid].cancel)
        events[resultEvent.uid].cancel()

      configureEventCronJob(resultEvent)



#When initializing, iterate over all events and set up timers for them
event.findAll(
  where: ['(dateTime >= NOW() and cronDaemonUid is NULL) or (dateTime < NOW() and cronDaemonUid is NULL)']
).success (resultEvents) ->

  for resultEvent in resultEvents
    configureEventCronJob(resultEvent)



configureEventCronJob = (eventObj) ->
  ((eventObj) ->


    #If this is a past event have it fire immediately.
    eventDate = new Date(eventObj.dateTime)
    if eventDate < (new Date())
      eventDate = new Date()


    events[eventObj.uid] = schedule.scheduleJob eventDate, () ->

      sequelize.query("UPDATE events SET cronDaemonUid = '" + cronDaemonUid + "' WHERE uid = '" + eventObj.uid + "' AND cronDaemonUid is null").success () ->

        event.find(
          where:
            uid:           eventObj.uid
            cronDaemonUid: cronDaemonUid
        ).success (resultEventObj) ->

          if !resultEventObj
            delete events[eventObj.uid]
            console.log 'events.length == ' + Object.getOwnPropertyNames(events).length
            return

          console.log 'EVENT: ' + resultEventObj.name + ' | Handled By: ' + cronDaemonUid


          #Create an activity item to let the user know that the event initiated
          activityInsert {
            type:      'eventInitialized'
            eventUid:  resultEventObj.uid
            clientUid: resultEventObj.clientUid
          }, app



          config.apiBroadcastPut(event, resultEventObj, app, {}, {})



          eventParticipant.findAll(
            where:
              eventUid: resultEventObj.uid
            include: [employee]
          ).success (resultEventParticipants) ->

            console.log 'Participants: ' + resultEventParticipants.length

            bodyMessage = 'Business Continuity Test ' + "\n" + '"' + resultEventObj.name + '" @ ' + (new Date (resultEventObj.dateTime)).toGMTString()

            for eP in resultEventParticipants
              ((participant) ->
                #Send email

                mandrill '/messages/send',
                  message:
                    to: [
                      name:  participant.employee.firstName + ' ' + participant.employee.lastName
                      email: participant.employee.email
                    ]
                    from_email: 'no-reply@cobarsystems.com'
                    from_name:  'Cobar Systems'
                    subject:    bodyMessage
                    text:      'http://lyssa.cobarsystems.com/#/exercises/' + participant.uid
                , (error, response) ->
                  #console.log arguments
                  #console.log response


                #Send text message in two parts

                twilioClient.sendSms {
                  to:   participant.employee.phone
                  from: '6172507514'
                  body: bodyMessage
                }, (error, message) ->

                  twilioClient.sendSms {
                    to:   participant.employee.phone
                    from: '6172507514'
                    body: 'http://lyssa.cobarsystems.com/#/exercises/' + participant.uid
                  }, (error, message) ->

                    #console.log arguments
              )(eP)


          delete events[resultEventObj.uid]
          console.log 'events.length == ' + Object.getOwnPropertyNames(events).length

  )(eventObj)


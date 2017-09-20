fat = require './fat'

class FakeRedis
    lrange:()->
      return {then: @then}
    lpush:()->
      return {then: @then}
    rpush:()->
      return {then: @then}
    get:()->
      return {then: @then}
    set:(key,value)->
      return {then: @then}
    setex:()->
      return {then: @then}
    expire:()->
      return {then: @then}
    then:(cb)->
      cb(false)
  global.redis = new FakeRedis()

class BotTest extends fat.Bot
  constructor: (cb) ->
    super()
    @help = ["Pomoč:"]
    @gcb = cb

  prepClient: ->
    @client  =
        
        say: ->
          return
        
        on: ->
          return

  say: (txt, chan) ->
    @gcb txt

  test: (message, cb)->
    @emit 'user:talk',
      nick: "mocha"
      channel: "TEST"
      text: message
      reply: (txt) ->
        #console.log "bot: #{txt}"
        cb txt
      privmsg: (txt) ->
        #console.log "privbot: #{txt}"
        cb txt

module.exports.BotTest = BotTest

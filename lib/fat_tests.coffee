fat = require './fat'

class TestRedis
    constructor: () ->

    lrange:()->
    lpush:()->
    rpush:()->

global.redis = new TestRedis()

class BotTest extends fat.Bot
  constructor: () ->
    @help = ["Pomoč:"]

  prepClient: ->
    @client  =
        say: console.log

  test: (message, cb)->
    @emit 'user:talk',
      nick: "mocha"
      channel: "TEST"
      text: message
      reply: (txt) =>
        #console.log "bot: #{txt}"
        cb txt
      privmsg: (txt) =>
        #console.log "privbot: #{txt}"
        cb txt

module.exports.BotTest = BotTest

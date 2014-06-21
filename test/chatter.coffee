chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'chatter.coffee', ->
  this.timeout 16000
  bot = require("../scripts/chatter")(new fat.BotTest())

  it 'test .pic dog', (done)->
    bot.test ".pic dog", (msg)->
        expect(msg).to.be.a('string')
        done()

  it 'test facepalm', (done)->
    bot.test "facepalm", (msg)->
        expect(msg).to.be.a('string')
        done()

  it 'test .gif get lucky', (done)->
    bot.test ".gif get lucky", (msg)->
        expect(msg).to.be.a('string')
        done()

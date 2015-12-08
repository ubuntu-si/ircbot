chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'chatter.coffee', ->
  this.timeout 16000
  bot = require("../scripts/chatter")(new fat.BotTest())

  it 'test .rainbow love', (done)->
    bot.test ".rainbow love", (msg)->
        console.log(msg)
        expect(msg).to.be.a('string')
        done()

  it 'test .gif get lucky', (done)->
    bot.test ".gif get lucky", (msg)->
        expect(msg).to.be.a('string')
        done()

  it 'test spread some love', (done)->
    bot.test "spread some love", (msg)->
        expect(msg).to.be.a('string')
        done()

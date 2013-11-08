chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'vreme.coffee', ->
  this.timeout 16000
  bot = require("../scripts/vreme")(new fat.BotTest())
  # generic test
  it 'should display help', (done)->
    bot.help.should.be.an 'array'
    expect(bot.help.length).to.be.at.least 2
    done()

  it 'test .prognoza', (done)->
    bot.test ".prognoza", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 140
      done()

  it 'test .napoved', (done)->
    bot.test ".napoved", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 140
      done()


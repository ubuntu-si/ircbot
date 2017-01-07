chai = require 'chai'
should = chai.should()
expect = chai.expect
MockDate = require 'mockdate'

fat = require '../lib/fat_tests'

describe 'forum.coffee', ->
  this.timeout 16000
  MockDate.set '1/1/2015'
  bot = require("../scripts/forum")
  it 'test forum ticker', (done)->
    fat = new fat.BotTest (msg) ->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 20
    bot.check_forum fat
    done()
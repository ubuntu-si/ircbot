chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'promet.coffee', ->
  this.timeout 16000
  bot = require("../scripts/promet")(new fat.BotTest())
  # generic test
  it 'should display help', (done)->
    bot.help.should.be.an 'array'
    expect(bot.help.length).to.be.at.least 2
    done()
    
   it 'test .promet', (done)->
     bot.test ".promet", (msg)->
        expect(msg).to.be.a('string')
        expect(msg.length).to.be.at.least 40
        done()

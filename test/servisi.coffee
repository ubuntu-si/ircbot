chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'servisi.coffee', ->
  this.timeout 16000
  bot = require("../scripts/servisi")(new fat.BotTest())
  # generic test
  it 'should display help', (done)->
    bot.help.should.be.an 'array'
    expect(bot.help.length).to.be.at.least 2
    done()

  it 'test .imdb American Pie', (done)->
    bot.test ".imdb American pie", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 140
      done()

  it 'test .imdb Iron Sky', (done)->
    bot.test ".imdb Iron Sky", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 140
      done()

  it 'test .imdb The Hobbit The Desolation of Smaug', (done)->
    bot.test ".imdb The Hobbit The Desolation of Smaug", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 140
      done()

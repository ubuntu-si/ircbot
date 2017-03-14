chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'servisi.coffee', ->
  this.timeout 16000
  bot = require("../scripts/servisi")(new fat.BotTest())

  it 'test .imdb helion', (done)->
    bot.test ".imdb helion", (msg)->
      expect(msg).to.be.a('string')
      expect(msg).to.equal "Ne najdem!"
      done()

  it 'test .stran ubuntu.si', (done)->
    bot.test ".stran ubuntu.si", (msg)->
        expect(msg).to.be.a('string')
        done()

  it 'test .stran localhost', (done)->
    bot.test ".stran localhost", (msg)->
        expect(msg).to.be.a('string')
        done()

  # generic test
  it 'should display help', (done)->
    bot.help.should.be.an 'array'
    expect(bot.help.length).to.be.at.least 2
    done()

  it 'test .imdb American Pie', (done)->
    bot.test ".imdb American pie", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 100
      done()

  it 'test .imdb Iron Sky', (done)->
    bot.test ".imdb Iron Sky", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 100
      done()

  it 'test .imdb mozje x', (done)->
    bot.test ".imdb mozje x", (msg)->
      expect(msg).to.be.a('string')
      done()

  it 'test .imdb The Hobbit: The Desolation of Smaug', (done)->
    bot.test ".imdb The Hobbit: The Desolation of Smaug", (msg)->
      expect(msg).to.be.a('string')
      expect(msg).to.not.equal "Ne najdem!"
      done()

  it 'test .rt', (done)->
    bot.test ".rt", (msg)->
      expect(msg).to.be.a('string')
      done()

  it 'test .yt AURORA Running With The Wolves', (done)->
    bot.test ".yt AURORA Running With The Wolves", (msg) ->
      expect(msg).to.be.a('string')
      done()

  it 'test .yt golden ticket higha', (done)->
    bot.test ".yt golden ticket higha", (msg) ->
      expect(msg).to.be.a('string')
      done()

  it 'test .pretvori', (done)->
    bot.test ".pretvori 10 EUR USD", (msg) ->
      expect(msg).to.be.a('string')
      done()

  it 'test .github spotify remote', (done)->
    bot.test ".github spotify remote", (msg) ->
      expect(msg).to.be.a('string')
      done()

  it 'test .sskj idiot', (done)->
    bot.test ".sskj idiot", (msg) ->
      expect(msg).to.be.a('string')
      done()

    it 'test .time ljubljana', (done)->
      bot.test ".time ljubljana", (msg) ->
        expect(msg).to.be.a('string')
        done()

  it 'test .val', (done)->
    bot.test ".val", (msg)->
      expect(msg).to.be.a('string')
      done()
<<<<<<< 50bf17a79698d8597b7413b8df0c6f452e4e45e9

=======
      
>>>>>>> added Bitstamp API
  it 'test .btc eur', (done)->
    bot.test ".btc eur", (msg) ->
      expect(msg).to.be.a('string')
      done()

  it 'test .btc usd', (done)->
    bot.test ".btc usd", (msg) ->
      expect(msg).to.be.a('string')
      done()

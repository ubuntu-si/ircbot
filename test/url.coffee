chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'url.coffee', ->
  this.timeout 1000
  bot = require("../scripts/url")(new fat.BotTest())
  # generic test
  it 'should display help', (done)->
    bot.help.should.be.an 'array'
    expect(bot.help.length).to.be.at.least 2
    done()

  it 'test .nalozi veljaven url', (done)->
    bot.test ".nalozi http://medialize.github.io/URI.js/docs.html#static-withinString", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 2
      done()

  it 'test .nalozi ne prikaze ce ni veljavnega urlja', (done)->
    bot.test ".nalozi medialize.github.io/URI.js/docs.html#static-withinString", (msg)->
      expect(msg).to.contain "Ni URL"
      done()

  it 'test .nalozi ne prikaze ce ni HTML', (done)->
    bot.test ".nalozi https://gist.github.com/dz0ny/59f7896355e6fe606d87/raw/6e5d5db6b9fd53738f7579d07cb1757de99b2d5d/gistfile1.js", (msg)->
      expect(msg).to.contain "Ni HTML"
      done()
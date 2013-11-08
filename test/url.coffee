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

  it 'test .nalozi ne prikaze ce ni veljavnega urlja', (done)->
    bot.test ".nalozi http://medialize.github.io/URI.js/docs.html#static-withinString", (msg)->
      expect(msg).to.not.contain "Ni URL"
      done()


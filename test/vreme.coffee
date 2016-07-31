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

   it 'test .obeti', (done)->
     bot.test ".obeti", (msg)->
       expect(msg).to.be.a('string')
       expect(msg.length).to.be.at.least 40
       done()

   it 'test .napoved', (done)->
     bot.test ".napoved", (msg)->
       expect(msg).to.be.a('string')
       expect(msg.length).to.be.at.least 40
       done()

  it 'test .vreme lj', (done)->
    bot.test ".vreme lj", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 20
      done()

  it 'test .vreme katarina pri ljubljani (oblacnost ter vremenski pojav pa brez vetra)', (done)->
    bot.test ".vreme boja", (msg)->
      expect(msg).to.be.a('string')
      done()

  it 'test .vreme new york', (done)->
    bot.test ".vreme new york", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 20
      done()

  it 'test .radar', (done)->
    bot.test ".radar", (msg)->
       expect(msg).to.be.equal('Radarska slika padavin: http://www.arso.gov.si/vreme/napovedi%20in%20podatki/radar_anim.gif\nSatelitska slika oblačnosti: http://www.arso.gov.si/vreme/napovedi%20in%20podatki/satelit.jpg')
       done()

  it 'test .toča', (done)->
    bot.test ".toča", (msg)->
     expect(msg).to.be.equal('Verjetnost toče: http://meteo.arso.gov.si//uploads/probase/www/warning/graphic/warning_hp-sr_si-sea_latest.jpg')
     done()

  it 'test .morje', (done)->
    bot.test ".morje", (msg)->
      expect(msg).to.be.a('string')
      expect(msg.length).to.be.at.least 40
      done()

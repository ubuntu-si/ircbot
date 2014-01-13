chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'apt.coffee', ->
  this.timeout 16000
  bot = require("../scripts/apt")(new fat.BotTest())

  it 'test .apt libssl-dev', (done)->
    bot.test ".apt libssl-dev", (msg)->
      expect(msg).to.be.a('string')
      msg.should.equal 'libssl-dev {lucid, lucid-updates, precise, precise-updates, quantal, quantal-updates, raring, raring-updates, saucy, saucy-updates, trusty}'
      done()

  it 'test .aptf evp.h', (done)->
    bot.test ".aptf evp.h", (msg)->
      expect(msg).to.be.a('string')
      msg.should.equal '/usr/include/hcrypto/evp.h > heimdal-dev\n/usr/include/heimdal/hcrypto/evp.h > heimdal-multidev\n/usr/include/openssl/evp.h > libssl-dev\n/usr/include/xmlsec1/xmlsec/openssl/evp.h > libxmlsec1-dev'
      done()

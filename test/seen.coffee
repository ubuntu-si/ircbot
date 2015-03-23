chai = require 'chai'
should = chai.should()
expect = chai.expect

fat = require '../lib/fat_tests'

describe 'seen.coffee', ->
  this.timeout 16000
  script = require("../scripts/seen")
  bot = require("../scripts/seen")(new fat.BotTest())

  it 'test .videl user', (done)->
    bot.test ".videl user", (msg)->
        expect(msg).to.be.a('string')
        done()

  it 'should strip _ from user_', ->
    msg = script.cleanName 'user_'
    msg.should.equal 'user'

  it 'should strip _ from user_', ->
    msg = script.cleanName 'user_'
    msg.should.equal 'user'

  it 'should strip @ from u1s@2e3r', ->
    msg = script.cleanName 'u1s@2e3r'
    msg.should.equal 'u1s2e3r'

  it 'should strip [,] from user[0]', ->
    msg = script.cleanName 'user[0]'
    msg.should.equal 'user0'
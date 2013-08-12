chai = require 'chai'
global.request = require 'request'
should = chai.should()
expect = chai.expect

url = require '../scripts/url'

describe 'URL basic', ->
  q = url

  it 'should have url resolver', (done)->
    should.exist q.resolve
    done()

describe 'URL resolve "http://www.theguardian.com/commentisfree/2013/aug/11/nsa-internet-surveillance-email"', ->
  this.timeout 16000
  q = url

  it 'should get some info about link', (done)->
    reply = (links)=>
      links.should.be.an 'string'
      expect(links.length).to.be.at.least 10
      done()
    r = {
        text: "http://www.theguardian.com/commentisfree/2013/aug/11/nsa-internet-surveillance-email",
        reply: reply
    }
    q.resolve r


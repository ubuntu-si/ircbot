chai = require 'chai'
should = chai.should()
expect = chai.expect

HowDoI = require '../scripts/lib/howdoi'

describe 'HowDoI basic', ->
  q = null

  it 'should have google resolver', ->
    q = new HowDoI
    should.exist q.get_google

  it 'should have duck resolver', ->
    q = new HowDoI
    should.exist q.get_duck

  it 'should be with empty question', ->
    q = new HowDoI
    should.not.exist q.what

  it 'should have defined user agent', ->
    q = new HowDoI
    should.exist q.agent

  it 'should have stackoverflow.com as default site', ->
    q = new HowDoI
    q.site.should.equal 'stackoverflow.com'

  it 'should have askubuntu.com as site', ->
    q = new HowDoI "", "askubuntu.com"
    q.site.should.equal 'askubuntu.com'

  it 'should accept string as question', ->
    q = new HowDoI 'make program'
    q.what.should.equal 'make program'

  it 'should strip "?" from question', ->
    q = new HowDoI 'make program??'
    q.what.should.equal 'make program'

  it 'should recognise !! as show most popular links only', ->
    q = new HowDoI 'make program !!'
    should.exist q.only_links
    q.only_links.should.equal true

describe 'HowDoI ask for "get porn in space"', ->
  this.timeout 6000
  q = null
  it 'should have "get porn in space" defined as question', ->
    q = new HowDoI 'get porn in space', "stackexchange.com"
    q.what.should.equal 'get porn in space'

  it 'should get some links from google', (done)->
    q.get_google (links)->
      links.should.be.an 'array'
      expect(links.length).to.be.at.least 2
      for link in links
        expect(link).to.contain 'http://'
        expect(link).to.contain 'questions/'
        expect(link).to.contain 'stackexchange.com/'
      done()

  it 'should get some links from duck', (done)->
    q.get_duck (links)->
      links.should.be.an 'array'
      expect(links.length).to.be.at.least 2
      for link in links
        expect(link).to.contain 'http://'
        expect(link).to.contain 'questions/'
        expect(link).to.contain 'stackexchange.com/'
      done()

  it 'should get some links from all providers', (done)->
    q.get_all (links)->
      links.should.be.an 'array'
      expect(links.length).to.be.at.least 2
      for link in links
        expect(link).to.contain 'http://'
        expect(link).to.contain 'questions/'
      done()

  it 'shoud give me some answer', (done)->
    q.get_answer (answer)->
      answer.should.be.an 'string'
      done()

  it 'should get some links from google on askubuntu', (done)->
    q = new HowDoI 'get modified files', "askubuntu.com"
    q.get_google (links)->
      links.should.be.an 'array'
      expect(links.length).to.be.at.least 2
      for link in links
        expect(link).to.contain 'http://'
        expect(link).to.contain 'questions/'
        expect(link).to.contain 'askubuntu.com/'
      done()

  it 'should get some links from duck on askubuntu', (done)->
    q.get_duck (links)->
      links.should.be.an 'array'
      expect(links.length).to.be.at.least 2
      for link in links
        expect(link).to.contain 'http://'
        expect(link).to.contain 'questions/'
        expect(link).to.contain 'askubuntu.com/'
      done()

  it 'should get some links from all providers on askubuntu', (done)->
    q.get_all (links)->
      links.should.be.an 'array'
      expect(links.length).to.be.at.least 2
      for link in links
        expect(link).to.contain 'http://'
        expect(link).to.contain 'questions/'
      done()

  it 'should give me some answer', (done)->
    q.get_answer (answer)->
      answer.should.be.an 'string'
      done()
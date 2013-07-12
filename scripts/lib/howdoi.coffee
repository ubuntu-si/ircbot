request = require 'request'
cheerio = require 'cheerio'
_ = require 'underscore'

class HowDoI
  constructor: (@what, @site="stackoverflow.com") ->
    @google_url = "https://www.google.com/search?q=site:#{@site}%20#{encodeURI(what)}"
    @duck_url = "http://duckduckgo.com/html?q=site%3A#{@site}%20#{encodeURI(what)}"
    @agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1500.71 Safari/537.36"
    if @what
      @what = @what.replace /\?+/g, ""
      @only_links = if /!!/.test @what then true else false
      if @only_links
        @what = @what.replace /!!/ ,""
      
  get_google:(cb)=>
    @get @google_url, (data)=>
      if data
        $ = cheerio.load(data)
        links = $('h3 a').map (i, el) ->
          return $(this).attr 'href'
        console.log @google_url
        console.log links
        cb(@filter(links))
      else
        cb([])  

  filter:(links)->
    links.filter (link)->
      /questions/.test link

  get_duck:(cb)=>
    @get @duck_url, (data)=>
      if data
        $ = cheerio.load(data)
        links = $('.links_main a').map (i, el) ->
          return $(this).attr 'href'
        cb(@filter(links))
      else
        cb([]) 
        
  get_all:(cb)=>
    @get_google (a)=>
      @get_duck (b)=>
        cb(_.union a,b)

  get_answer:(cb)=>
    @get_all (links)=>
      unless @only_links
        link = "#{links[0]}/?answertab=votes"
        @get link, (page)=>
          $ = cheerio.load(page)
          answer = $(".answer").first()
          instructions = answer.find('pre') or answer.find('code')

          unless instructions.length
            text = answer.find('.post-text').text()
          else
            text = instructions.text()

          spliced = text.split("\n")
          if spliced.length > 2
            text = "#{spliced[0]}\n#{spliced[1]}" 
          if text.length > 140 || spliced.length > 2
            text = "#{text.slice(0,140)}... #{links[0]}"         
          cb(text)
      else
        text = ""
        i = 0
        for link in links
          a = "#{text} #{link}\n"
          text = a
          if i > 3
            break
          i++
        cb(text.slice(0, -1))

  get:(url, cb)=>
    request.get {url:url, headers:{
      "User-Agent": @agent
      "Accept-Language": "sl-SI,sl;q=0.8,en-GB;q=0.6,en;q=0.4"
    }}, (e,r,j)=>
      if e
        cb(false)
      else
        cb(j)
  


module.exports = HowDoI
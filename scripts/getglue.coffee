youtube = require("youtube-feeds")
youtube.httpProtocol = "https"
humanize = require 'humanize'
HowDoI = require './lib/howdoi'
cheerio = require 'cheerio'

gimdb = (naslov, cb)->
  fetch "http://www.omdbapi.com/?t=#{encodeURI(naslov)}", (data)-> 
    if data
      cb data.imdbRating
    else
      cb "NP"

gimdb2 = (naslov, cb)->
  fetch "http://www.omdbapi.com/?t=#{encodeURI(naslov)}", (data)-> 
    if data
      cb "#{data.Title} (#{data.Year}) - #{data.imdbRating}(✋ #{data.imdbVotes) http://imdb.com/title/#{data.imdbID}\n#{data.Plot}"
    else
      cb "NP"

gimdb = (naslov, cb)->
  fetch "http://www.omdbapi.com/?t=#{encodeURI(naslov)}", (data)-> 
    if data
      cb data.imdbRating
    else
      cb "NP"

fixyt = (url)->
  if url
    return url.replace("/v/", "/watch?v=").replace("&feature=youtube_gdata_player", "")
  else
    return ""

random = (ar)->
  return ar[Math.floor(Math.random() * ar.length)];

yt = (qq, cb) ->
  youtube.feeds.videos
    q: qq
    "max-results": 5
  , (err, data) ->
    unless err
      cb fixyt(_.first(data.items).player.default)
    else
      cb "Ni zadetka"

fetch = (url, cb)->
  request.get url, (e, r, body)->
    if !e and r.statusCode is 200
      cb(JSON.parse(body))
    else
      logger.log e
      cb false

_get = (api, cb)->
    url = "http://ws.guide.getglue.com/v4/#{api}&token=c817f58e3843bfc50863c1cc5973d53b&app=WebsiteHD"
    fetch url, cb

_object = (api, cb)->

    url = "http://ws.guide.getglue.com/v4/objects/#{api}?token=hOAksHX9QsObO24IbywobRCkMYbDg9yIp7KVp3Cf8Vtf-1617243277&app=WebsiteHD"
    fetch url, cb

najdifilm = (naslov, cb)->
    _get "search/objects?q=#{encodeURI(naslov)}&category=movies", (data)->
      if data and data.objects.length > 0
        _object _.first(data.objects).id, (t)->
          if t.trailer_link
            cb "#{t.title} (#{t.year}) - #{fixyt(t.trailer_link)} #{t.summary}"
          else
            yt "#{t.title} #{t.director} #{t.year} trailer", (trailer)->
              cb "#{t.title} (#{t.year}) - #{fixyt(trailer)} #{t.summary}"

najditv = (naslov, cb)->
    _get "search/objects?q=#{encodeURI(naslov)}&category=tv_shows", (data)->
      if data and data.objects.length > 0
        _object _.first(data.objects).id, (t)->
          yt "#{t.title} trailer", (trailer)->
            cb "#{t.title} - #{t.trailer} #{t.summary}"


apt = (paket, cb)=>
  url = "http://packages.ubuntu.com/search?suite=all&searchon=names&keywords=#{encodeURI(paket)}"
  request.get url, (e, r, body)->
    if !e and r.statusCode is 200
      $ = cheerio.load(body)
      paketi = $("#psearchres h3").map (i, el) ->
          return $(this).text()
      cisti = []
      for paket in paketi
        cisti.push paket.replace "Package ", ""
      cb cisti.join ", "
    else
      logger.log e
      cb "Ne najdem"

aptd = (paket, cb)=>
  url = "http://packages.ubuntu.com/search?suite=all&searchon=all&keywords=#{encodeURI(paket)}"
  request.get url, (e, r, body)->
    if !e and r.statusCode is 200
      $ = cheerio.load(body)
      paketi = $("#psearchres h3").map (i, el) ->
          return $(this).text()
      cisti = []
      for paket in paketi
        cisti.push paket.replace "Package ", ""
      cb cisti.join ", "
    else
      logger.log e
      cb "Ne najdem"

deb = (paket, cb)=>
  url = "http://packages.ubuntu.com/search?suite=all&arch=any&searchon=names&exact=1&keywords=#{encodeURI(paket)}"
  request.get url, (e, r, body)->
    if !e and r.statusCode is 200
      $ = cheerio.load(body)
      paketi = $("#psearchres h3").map (i, el) ->
          return $(this).text()
      cisti = []
      for paket in paketi
        cisti.push paket.replace "Package ", ""
      cb cisti.join ", "
    else
      logger.log e
      cb "Ne najdem"

module.exports = (bot) ->

  bot.regexp /^.yt (.+)/,
    ".yt <iskalni niz> -- Išči na youtube",
    (match, r) ->
      f = match[1].trim()
      youtube.feeds.videos
        q: f
        "max-results": 5
      , (err, data) ->
        unless err
          izbran = _.first(data.items)
          r.reply "#{izbran.title}(#{moment.duration(izbran.duration, 'seconds').humanize()}) #{fixyt(izbran.player.default)} ♥#{humanize.numberFormat(izbran.likeCount,0)} ▶#{humanize.numberFormat(izbran.viewCount,0)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^.sc (.+)/,
    ".sc <iskalni niz> -- Išči na soundcloud",
    (match, r) ->
      f = match[1].trim()
      fetch "http://api.soundcloud.com/tracks.json?order=hotness&client_id=93e33e327fd8a9b77becd179652272e2&q=#{encodeURI(f)}", (data) ->
        if data
          izbran = _.first(data)
          r.reply "#{izbran.title}(#{moment.duration(izbran.duration).humanize()}) #{izbran.permalink_url} ♥#{humanize.numberFormat(izbran.favoritings_count,0)} ▶#{humanize.numberFormat(izbran.playback_count,0)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^.film (.+)/,
    ".film <delni naslov> -- Dobi podatke o filmu",
    (match, r) ->
      f = match[1].trim()
      najdifilm f, r.reply
  
  bot.regexp /^.tv (.+)/,
    ".tv <delni naslov> -- Dobi podatke o seriji",
    (match, r) ->
      f = match[1].trim()
      najditv f, r.reply 

  bot.regexp /^.asku (.+)/,
    ".asku <pojem> -- Išči po askubuntu, če vsebuje !! potem prikaže povezave",
    (match, r) ->
      f = match[1].trim()
      res = new HowDoI f, "askubuntu.com"
      res.get_answer (answer)->
        r.reply answer

  bot.regexp /^.stof (.+)/,
    ".stof <pojem> -- Išči po stackoverflow, če vsebuje !! potem prikaže povezave",
    (match, r) ->
      f = match[1].trim()
      res = new HowDoI f, "stackoverflow.com"
      res.get_answer (answer)->
        r.reply answer

  bot.regexp /^.stx (.+)/,
    ".stx <pojem> -- Išči po stackexchange, če vsebuje !! potem prikaže povezave",
    (match, r) ->
      f = match[1].trim()
      res = new HowDoI f, "stackexchange.com"
      res.get_answer (answer)->
        r.reply answer

  bot.regexp /^.apt (.+)/,
    ".apt <paket> -- Najde pakete po imenu v packages.ubuntu.com",
    (match, r) ->
      f = match[1].trim()
      apt f, (answer)->
        r.reply answer

  bot.regexp /^.aptd (.+)/,
    ".aptd <opis> -- Najde pakete po opisu v packages.ubuntu.com",
    (match, r) ->
      f = match[1].trim()
      apt f, (answer)->
        r.reply answer

  bot.regexp /^.deb (.+)/,
    ".deb <paket> -- Najde paket po imenu in prikaže opis ter izdaje",
    (match, r) ->
      f = match[1].trim()
      deb f, (answer)->
        r.reply answer

  bot.regexp /^.imdb (.+)/,
    ".imdb <naslov> -- Dobi osnovne podatke z IMBD ",
    (match, r) ->
      f = match[1].trim()
      gimdb2 f, (answer)->
        r.reply answer
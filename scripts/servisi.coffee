youtube = require("youtube-feeds")
youtube.httpProtocol = "https"
humanize = require 'humanize'
HowDoI = require './lib/howdoi'
mathjs = require('mathjs')()

module.exports = (bot) ->

  bot.regexp /^.yt (.+)/,
    ".yt <iskalni niz> -- Išči na youtube",
    (match, r) ->

      fixyt = (url)->
        if url
          return url.replace("/v/", "/watch?v=").replace("&feature=youtube_gdata_player", "")
        else
          return ""

      f = match[1].trim()
      youtube.feeds.videos
        q: f
        "max-results": 5
      , (err, data) ->
        unless err
          izbran = _.first(data.items)
          r.reply "#{izbran.title} (#{moment.duration(izbran.duration, 'seconds').humanize()}) #{fixyt(izbran.player.default)} ♥#{humanize.numberFormat(izbran.likeCount,0)} ▶#{humanize.numberFormat(izbran.viewCount,0)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^.sc (.+)/,
    ".sc <iskalni niz> -- Išči na soundcloud",
    (match, r) ->
      f = match[1].trim()
      bot.fetchJSON "http://api.soundcloud.com/tracks.json?order=hotness&client_id=93e33e327fd8a9b77becd179652272e2&q=#{encodeURI(f)}", (data) ->
        if data
          izbran = _.first(data)
          r.reply "#{izbran.title}(#{moment.duration(izbran.duration).humanize()}) #{izbran.permalink_url} ♥#{humanize.numberFormat(izbran.favoritings_count,0)} ▶#{humanize.numberFormat(izbran.playback_count,0)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^.calc (.+)/,
    ".calc <enačba> -- Izračunaj",
    (match, r) ->
      f = match[1].trim()
      res = mathjs.eval(f)
      if res.value?
        r.reply String(res.value.toFixed(2))
      else 
        r.reply String(res.toFixed(2))

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
      
  bot.regexp /^.pretvori ([\d,.]+) (.+) (.+)/,
    ".pretvori <vrednost> <valuta> <valuta> -- Pretvori med valutami (primer .pretvori 10 eur usd)",
    (match, r) ->

      zamenjaj = (v, f, t, cb)=>
        url = "http://rate-exchange.appspot.com/currency?from=#{f}&to=#{t}"
        v = Number(v.replace(",","."))
        
        if v
          request.get url, (e, r, body)->
            if !e and r.statusCode is 200
              rate = Number(JSON.parse(body).rate)
              cb "#{v * rate} #{t}"
            else
              console.log e
              cb "Napaka"
        else
          cb "Napaka"

      vrednost = match[1].trim()
      from = match[2].trim()
      to = match[3].trim()
      zamenjaj vrednost, from, to, (answer)->
        r.reply "#{r.nick}: #{answer}"

  bot.regexp /^.imdb (.+)/,
    ".imdb <naslov> -- Dobi osnovne podatke z IMBD ",
    (match, r) ->
      f = match[1].trim()

      imdb = (ime, cb)->
        url = "http://www.imdb.com/find?q=#{encodeURI(ime)}&s=all"
        bot.fetchHTML url, ($)->
          naslov = $(".findResult:first-child .result_text a").text()
          url_filma = $(".findResult:first-child .result_text a").attr("href")

          if url_filma?
            url_filma = "http://www.imdb.com#{url_filma}"
            bot.fetchHTML url_filma, ($)->
              ocena = $(".star-box-details a").eq(0).attr("title")
              if ocena?
                ocena = ocena.split(" IMDb users have given a weighted average vote of ").reverse()
                ocena = "#{ocena[0]} (#{ocena[1]} glasov)"
                metascore = $(".star-box-details a").eq(1).text().replace(/[\n\r]/gm,"").replace(/\s+/,"")
              else
                ocena = "Ni podatka"
                metascore = "Ni podatka"
              opis = $("p[itemprop=\"description\"]").text().replace(/[\n\r]/gm,"").replace(/\s\s/g,"")
              cas = $(".infobar time[itemprop=\"duration\"]").text().replace(/[\n\r]/gm,"").replace(/\s\s/g,"")
              naslov = $("title").text().replace(" - IMDb", "")
              trailer = $("a[itemprop=\"trailer\"]").attr("href")
              if trailer?
                trailer = "http://www.imdb.com#{trailer}"
                msg = "#{naslov} #{cas}\nOcena: #{ocena} MT: #{metascore}\n#{opis}\nTrailer:#{trailer}\nPovezava:#{url_filma}"
              else
                msg = "#{naslov} #{cas}\nOcena: #{ocena} MT: #{metascore}\n#{opis}\nPovezava:#{url_filma}"
              
              console.log msg
              cb msg
          else
            cb "Ne najdem!"

      imdb f, r.reply

    bot.regexp /^\.stran (.*)/i,
      ".stran <domena> -- Ali stran dela?",
      (match, irc) ->
        domena = match[1].trim()
        url = "http://isup.me/#{domena}"
        bot.fetch url, (error, response, body)->
          if !error and response.statusCode is 200
            dostopna = body.indexOf("is up")
            if dostopna != -1
              irc.reply "#{domena} je dosegljiva!"
            else
              irc.reply "#{domena} ni dosegljiva"
          else
            irc.reply "http://isup.me ni na voljo!"

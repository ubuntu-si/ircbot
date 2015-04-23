google = require('googleapis')
google.options ({ auth: 'AIzaSyAl1Xq9DwdE_KD4AtPaE4EJl3WZe2zCqg4' });
youtube = google.youtube ('v3')
humanize = require 'humanize'

module.exports = (bot) ->

  bot.regexp /^.yt (.+)/,
    ".yt <iskalni niz> -- Išči na youtube",
    (match, r) ->
      youtube.search.list {
          part: 'snippet'
          type: 'video'
          q: match[1].trim()
          maxResults: 5
          type: 'video'
          order: 'relevance'
          safeSearch: 'none'
      }, (err, res) ->
        unless err
          izbran = _.first(res.items)
          r.reply "#{izbran.snippet.title} https://www.youtube.com/watch?v=#{izbran.id.videoId}"
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
              vsota = Number(v * rate).toFixed(2)
              cb "#{vsota} #{t}"
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
        url = "http://www.imdb.com/find?q=#{encodeURI(ime)}&s=tt&&exact=true&ref_=fn_tt_ex"
        bot.fetchHTML url, ($)->
          hit = $(".findResult:first-child .result_text a")
          if hit.length
            naslov = hit.text()
            url_filma = hit.attr("href").split("?")[0]
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
              zanr = $(".infobar a span[itemprop=\"genre\"]").text().match(/[A-z][a-z]+/g).join(" ")
              naslov = $("title").text().replace(" - IMDb", "")
              trailer = $("a[itemprop=\"trailer\"]").attr("href")
              if trailer?
                trailer = "http://www.imdb.com#{trailer}"
                msg = "#{naslov} #{cas} #{zanr}\nOcena: #{ocena} MT: #{metascore}\n#{opis}\nTrailer: #{trailer.split("?")[0]}\nPovezava: #{url_filma}"
              else
                msg = "#{naslov} #{cas} #{zanr}\nOcena: #{ocena} MT: #{metascore}\n#{opis}\nPovezava: #{url_filma}"

              console.log msg
              redis.setex("imdb:#{ime}", 24*60*5, msg)
              cb msg
          else
            cb "Ne najdem!"

      redis.get("imdb:#{f}").then (res)->
        unless res
          imdb f, r.reply
        else
          r.reply res

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

    bot.regexp /^\.rt/,
      ".rt -- kaj se trenutno predvaja na radioterminal.si",
      (match,irc) ->
        bot.fetchJSON "http://m.radioterminal.si/zgodovina/sedaj.json", (data) ->
          if data
            if (data.ytid)
              ytlink = "https://www.youtube.com/watch?v=#{data.ytid}"
            else
              ytlink = ""
            irc.reply "Trenutno se predvaja: #{data.artist} - #{data.track}. #{ytlink}"
            console.log "Trenutno se predvaja: #{data.artist} - #{data.track}. #{ytlink}"
          else
            irc.reply "OMG radioterminal.si is down!"

    bot.regexp /^\.morje/,
      ".morje -- kakšne so trenutno temperature v slovenskem morju",
      (match,irc) ->
        urls = [
          "http://www.arso.gov.si/vode/podatki/amp/H17_t_1.html", #koper
          "http://www.arso.gov.si/vode/podatki/amp/H64_t_1.html", #rtic
          "http://www.arso.gov.si/vode/podatki/amp/H24_t_1.html", #piran
        ]
        msg = []
        for url, index in urls
          bot.fetchHTML url, ($) ->
            postaja = $(".vsebina h1").text()
            if postaja is "Postaja Koper - kapitanija - Jadransko morje"
              temperatura = $(".podatki tr td").eq(2).text()
            else
              temperatura = $(".podatki tr td").eq(1).text()
            if temperatura != '-'
              msg.push "#{postaja}: #{temperatura}°C"
            else
              msg.push "#{postaja}: Temperatura ni na voljo"
            if msg.length == urls.length
              irc.reply msg.join('\n')

google = require('googleapis')
google.options ({ auth: 'AIzaSyAl1Xq9DwdE_KD4AtPaE4EJl3WZe2zCqg4' });
youtube = google.youtube ('v3')
humanize = require 'humanize'

module.exports = (bot) ->

  bot.regexp /^\.yt (.+)/,
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
          if izbran
            r.reply "#{izbran.snippet.title} https://www.youtube.com/watch?v=#{izbran.id.videoId}"
          else
            r.reply "Ni zadetka"
        else
          r.reply "Ni zadetka"

  bot.regexp /^\.sc (.+)/,
    ".sc <iskalni niz> -- Išči na soundcloud",
    (match, r) ->
      f = match[1].trim()
      bot.fetchJSON "http://api.soundcloud.com/tracks.json?order=hotness&client_id=93e33e327fd8a9b77becd179652272e2&q=#{encodeURI(f)}", (data) ->
        if data
          izbran = _.first(data)
          r.reply "#{izbran.title}(#{moment.duration(izbran.duration).humanize()}) #{izbran.permalink_url} ♥#{humanize.numberFormat(izbran.likes_count,0)} ▶#{humanize.numberFormat(izbran.playback_count,0)}"
        else
          r.reply "Ni zadetka"

  bot.regexp /^\.pretvori ([\d,.]+) (.+) (.+)/,
    ".pretvori <vrednost> <valuta> <valuta> -- Pretvori med valutami (primer .pretvori 10 eur usd)",
    (match, r) ->

      zamenjaj = (v, f, t, cb)=>
        cached_time = 24 * 60 #1 day
        url = "https://api.fixer.io/latest?base=#{f}"
        v = Number(v.replace(",","."))
        bot.fetchJSONCached redis, cached_time, url, (res) ->
          unless res
            cb "Sowwy but something went wrong"
          else
            for key, value of res.rates
              if key is t.toUpperCase()
                vsota = Number(value * v).toFixed(2)
                cb "#{v} #{f.toUpperCase()} je #{vsota} #{key}"

      vrednost = match[1].trim()
      from = match[2].trim()
      to = match[3].trim()
      zamenjaj vrednost, from, to, (answer)->
        r.reply "#{r.nick}: #{answer}"

  bot.regexp /^\.imdb (.+)/,
    ".imdb <naslov> -- Dobi osnovne podatke z OMDB ",
    (match, r) ->
      f = match[1].trim()
      imdb = (ime, cb)->
        url = "http://www.omdbapi.com/?t=#{ime}&y=&r=json&tomatoes=true"
        bot.fetchJSON url, (data) ->
          if data.Response == "False"
            msg = "Ne najdem!"
            #console.log msg
            cb msg
          if data.Response == "True"
            msg = "#{data.Title} |#{data.Released} #{data.Runtime}| #{data.Genre}\n#{data.Plot}\nIMDB:#{data.imdbRating}/10 (#{data.imdbVotes} glasov) | Tomato: #{data.tomatoRating}/10 #{data.tomatoReviews} reviews (users: #{data.tomatoUserRating}/5 #{data.tomatoUserReviews} reviews) \
            \nPovezava: https://www.imdb.com/title/#{data.imdbID}"
            #console.log msg
            redis.setex("imdb:#{ime}", 24*60*5, msg)
            cb msg

      redis.get("imdb:#{f}").then (res)->
        unless res
          imdb f, r.reply
        else
          r.reply res

  bot.regexp /^\.stran (.*)/i,
    ".stran <domena> -- Ali stran dela?",
    (match, irc) ->
      httpmatch = /^(http|https):\/\//
      domena = match[1].trim().replace(httpmatch,'')
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
          #console.log "Trenutno se predvaja: #{data.artist} - #{data.track}. #{ytlink}"
        else
          irc.reply "OMG radioterminal.si is down!"

  bot.regexp /^\.github (.+)/,
    ".github <niz> -- išče <niz> po opisih ter imenih skladišč na githubu",
    (match, r) ->
      f = match[1].trim().replace(" ","+")

      bot.fetchJSON "https://api.github.com/search/repositories?q=#{f}&order=desc", (data) ->
        msg = ""
        if data.total_count >= 3
          for i in [0 .. 2]
            bestMatch = data.items[i]
            msg += "#{bestMatch.html_url}\n---#{bestMatch.description}\n\n"
          r.reply "#{msg}"
        else if data.total_count < 3 && data.total_count > 0
            bestMatch = data.items[0]
            msg = "#{bestMatch.html_url}\n---#{bestMatch.description}"
            r.reply "#{msg}"
          else if data.total_count < 3 && data.total_count > 0
              bestMatch = data.items[0]
              msg = "#{bestMatch.html_url}\n---#{bestMatch.description}"
              r.reply "#{msg}"
          else
            r.reply "Ni zadetkov :("

    bot.regexp /^\.sskj (.+)/,
      ".sskj <niz> -- išče <niz> v SSKJ (fran.si) in izpiše prvo ujemanje",
      (match, r) ->
        f = match[1].trim().replace(" ","+")
        url = "http://www.fran.si/iskanje?View=1&Query=#{encodeURI(f)}"
        bot.fetchHTML  url, ($) ->
          if $? &&  $(".fran-left-content").text().indexOf("Število zadetkov") != -1
            $(".entry-citation").remove()
            result = $(".results .entry .entry-content").eq(0).text().replace(/\s\s+/g, "")
            r.reply "#{result.substring(0,1024)}"
          else
            r.reply "Ni zadetkov"

    bot.regexp /^\.time (.+)/,
     ".time <mesto> - izpiše trenutni čas v $mesto",
     (match, r) ->
       f = match[1].trim().replace(" ","-")
       bot.fetchJSON "https://api.mkfs.si/time/#{f}", (data) ->
        if data && ! null
          r.reply "Trenutni čas v #{data.place} je #{data.short_time}"
        else
          r.reply "Trenutni čas je čas za $YOLO!"

    bot.regexp /^\.val/,
      ".val -- kaj se trenutno predvaja na Val 202",
      (match,irc) ->
        bot.fetchJSON "http://api.rtvslo.si/onair/val202", (data) ->
          if data
            irc.reply "Trenutno se predvaja: #{data.response.BroadcastMonitor.Current.artistName} - #{data.response.BroadcastMonitor.Current.titleName}"
          else
            irc.reply "OMG val202 is down!"

    bot.regexp /^\.btc (.+)/,
      ".btc <valuta> - izpiše trenutno BTC vrednost na Bitstamp",
        (match, r) ->
          currency = match[1].toLowerCase()
          if currency == "eur" || currency == "usd"
            bot.fetchJSON "https://www.bitstamp.net/api/v2/ticker/btc#{currency}/", (data) ->
              if data && ! null
                r.reply "Vrednost BTC v #{currency.toUpperCase()}: last: #{data.last}, low: #{data.low}, high: #{data.high}, bid: #{data.bid}, ask: #{data.ask}"
              else
                r.reply "Bitstamp is down"

    bot.regexp /^\.xkcd\s?(.+)?/,
        (match, r) ->
          if match[1] == "help"
            r.reply "Za prikaz zadnjega vnosa na xkcd.com vnesi ukaz '.xkcd', za prikaz naključnega vnosa vnesi '.xkcd random'"
          else if match[1] == "random"
             bot.fetchJSON "https://xkcd.com/info.0.json", (data) ->
              if data && ! null
                max = data.num
                random = Math.floor(Math.random() * (max - 1) + 1)
                bot.fetchJSON "https://xkcd.com/#{random}/info.0.json", (data2) ->
                  if data2 && ! null
                    r.reply "#{data2.safe_title}: #{data2.img}"
                  else
                    r.reply "Ne najdem"
          else if match[1] == undefined
            bot.fetchJSON "https://xkcd.com/info.0.json", (data) ->
                if data && ! null
                  r.reply "#{data.safe_title}: #{data.img}"
                else
                  r.reply "Ne najdem" 
          else
            r.reply "Ne najdem"
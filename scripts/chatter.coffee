ddg = require('ddg')

module.exports = (bot) ->

  bot.regexp /^ping$/i, (match, r) ->
    r.reply "#{r.nick}: pong"

  bot.regexp /^\.aww/i, (match, r) ->
    bot.fetchJSON "http://www.reddit.com/r/aww.json", (result)->
      if result.data.children.count <= 0
        msg.send "Couldn't find anything cute..."
        return

      urls = [ ]
      for child in result.data.children
        urls.push(child.data.url)

      r.reply bot.random urls

  bot.command /facepalm/i, (r) ->
    bot.fetchJSON "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=facepalm", (data)->
      r.reply bot.random(data.responseData.results).unescapedUrl

  bot.command /^wat/i, (r) ->
    bot.fetchJSON "http://watme.herokuapp.com/random", (data)->
      r.reply data.wat

  bot.command /lignux/i, (r) ->
    r.reply "#{r.nick}: linux*"

  bot.command /^YES yes/i, (r) ->
    r.reply "The YES dance\nhttps://www.youtube.com/watch?v=eyqUj3PGHv4"

  bot.regexp /^\.vrzi/,
    ".vrzi -- Glava ali cifra",
    (match, r) ->
      r.reply bot.random ["glava", "cifra"]

  bot.regexp /^\.pic (.+)/,
    ".pic <query> -- Prikaži naključno sliko",
    (match, r) ->
      url = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{encodeURI(match[1].trim())}"
      #console.log url
      bot.fetchJSONCached redis, 60*60, url, (data)->
        #console.log data
        r.reply bot.random(data.responseData.results).unescapedUrl

  bot.regexp /^\.roll (.+)/,
    ".roll <izbira1,izbira2,...> -- Universe has all the answers",
    (match, r) ->
      select = match[1].trim().split(",")
      r.reply bot.random select

  bot.regexp /^\.ac (.+)/,
    ".ac <?> -- for what",
    (match, r) ->
      select = match[1].trim()
      r.reply "http://achievement-unlocked.heroku.com/xbox/#{escape(select)}.png"

  bot.command /^\.plosk/i,
    ".plosk -- Zaploskaj",
    (r) ->
      huh = [
        "http://i.imgur.com/pfrtv6H.gif",
        "http://i.imgur.com/Bp4P8l3.gif",
        "http://i.imgur.com/v7mZ22P.gif",
        "http://i.imgur.com/S1v4KuY.gif",
        "http://i.imgur.com/YTaSAkq.gif",
        "http://i.imgur.com/JO6Wz3r.gif",
        "http://i.imgur.com/pWEd6cF.gif",
        "http://i.imgur.com/zumSlIA.gif",
        "http://i.imgur.com/RGczKmV.gif",
        "http://i.imgur.com/KAQhoCm.gif",
        "http://i.imgur.com/PASRKXo.gif",
        "http://i.imgur.com/ZOWQTO6.gif",
        "http://i.imgur.com/cY0eH5c.gif",
        "http://i.imgur.com/wf5qvOM.gif",
        "http://i.imgur.com/9Zv4V.gif",
        "http://i.imgur.com/t8zvc.gif",
        "http://cache.blippitt.com/wp-content/uploads/2012/06/Daily-Life-GIFs-06-The-Rock-Clapping.gif",
        "http://25.media.tumblr.com/tumblr_m00e9mCyWj1rqtbn0o1_500.gif"
        "http://assets0.ordienetworks.com/images/GifGuide/clapping/Kurtclapping.gif",
        "http://assets0.ordienetworks.com/images/GifGuide/clapping/riker.gif",
        "http://assets0.ordienetworks.com/images/GifGuide/clapping/hp3.gif",
        "http://assets0.ordienetworks.com/images/GifGuide/clapping/1292223254212-dumpfm-mario-Obamaclap.gif",
        "http://www.reactiongifs.com/wp-content/uploads/2013/01/applause.gif",
        "http://i.imgur.com/2QXgcqP.gif",
        "http://i.imgur.com/Yih2Lcg.gif",
        "http://i.imgur.com/un3MuET.gif",
        "http://i.imgur.com/H2wPc1d.gif",
        "http://i.imgur.com/uOtALBE.gif",
        "http://i.imgur.com/nmqrdiF.gif",
        "http://i.imgur.com/GgxOUGt.gif",
        "http://i.imgur.com/wyTQMD6.gif",
        "http://i.imgur.com/GYRGOy6.gif",
        "http://i.imgur.com/ojIsLUA.gif",
        "http://i.imgur.com/bRetADl.gif",
        "http://i.imgur.com/814mkEC.gif",
        "http://i.imgur.com/uYryMyr.gif",
        "http://i.imgur.com/YfrikPR.gif",
        "http://i.imgur.com/sBEFqYR.gif",
        "http://i.imgur.com/Sx8iAS8.gif",
        "http://i.imgur.com/5zKXz.gif",
        "Chapeau! http://www.youtube.com/watch?v=TAryFIuRxmQ"
      ]
      r.reply bot.random huh

  bot.regexp /^\.ddg (.+)/,
    ".ddg -- Vse kar zna https://api.duckduckgo.com/api ali https://api.duckduckgo.com/goodies",
    (match, r) ->
      options =
        useragent: "ubuntu.si"
        no_redirects: "1"
        no_html: "1"

      ddg.query match[1].trim(), options, (err, data) ->
        r.reply data.AbstractText
        r.reply data.Definition
        r.reply data.Answer
        r.reply data.AbstractURL || data.Redirect

  bot.regexp /^\.gif (.+)/, ".gif <query> -- Prikaže naključni gif", (match, r) ->
      url = "http://giphy.com/search/#{encodeURI(match[1].trim().split(" ").join("-"))}"
      bot.fetchHTML url, ($) ->
        count = $("#searchresults .found-count").text().split(" GIFs found for")
        if count[0] > 0
          gif_id = $(".hoverable-gif a").eq(0).attr("data-id")
          r.reply "http://media.giphy.com/media/#{gif_id}/giphy.gif"
        else
          console.log "No gif available :("
          r.reply "No gif available :("

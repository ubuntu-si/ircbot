colors = require('irc-colors')

module.exports = (bot) ->

  bot.regexp /^ping$/i, (match, r) ->
    r.reply "#{r.nick}: pong"

  bot.command /^\aww/i, (r) ->
    bot.fetchJSON "http://www.reddit.com/r/aww.json", (result)->
      if result.data.children.count <= 0
        msg.send "Couldn't find anything cute..."
        return

      urls = [ ]
      for child in result.data.children
        urls.push(child.data.url)

      r.reply bot.random urls

  bot.command /lol no/i, (r) ->
    r.reply "https://i.imgur.com/BiSkH5D.png"

  bot.command /lignux/i, (r) ->
    r.reply "#{r.nick}: linux*"

  bot.command /^YES yes/i, (r) ->
    r.reply "The YES dance\nhttps://www.youtube.com/watch?v=eyqUj3PGHv4"

  bot.regexp /^\.vrzi/,
    ".vrzi -- Glava ali cifra",
    (match, r) ->
      r.reply bot.random ["glava", "cifra"]

    bot.regexp /^\.roll (.+)/,
    ".roll <izbira1,izbira2,...> -- Universe has all the answers",
    (match, r) ->
      select = match[1].trim().split(",")
      r.reply bot.random select

  bot.regexp /^\.rainbow (.+)/,
    ".rainbow <msg> -- It's what we fought for",
    (match, r) ->
      text = match[1].trim()
      r.reply colors.rainbow(text)

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

  bot.command /(\bwin\b|victory)/i, (r) ->
    vic = [
      "http://thejointblog.com/wp-content/uploads/2013/04/victory.jpg",
      "http://www.quickmeme.com/img/ea/ea4671998341d9fbb6f7815394b49cb2890a50ac80b62802fb021c147c068d8e.jpg",
      "http://cdn-media.hollywood.com/images/l/victory_620_080712.jpg",
      "http://cf.chucklesnetwork.agj.co/items/5/5/9/6/0/one-does-not-simply-declare-victory-but-i-just-did.jpg",
      "http://www.artschoolgeek.com/wp-content/uploads/2014/06/h7E4B96E6.jpeg",
      "http://t.qkme.me/3qlspk.jpg",
      "http://img.pandawhale.com/86036-victory-dance-gif-Despicable-M-EPnS.gif",
      "http://1.bp.blogspot.com/-rmJLwpPevTg/UOEBgVNiVFI/AAAAAAAAFFY/-At3Z_DzBbw/s1600/dancing+charlie+murphy+animated+gif+victory+dance.gif",
      "http://www.gifbin.com/bin/20048442yu.gif",
      "http://www.quickmeme.com/img/30/300ace809c3c2dca48f2f55ca39cbab24693a9bd470867d2eb4e869c645acd42.jpg",
      "http://jeffatom.files.wordpress.com/2013/09/winston-churchill-says-we-deserve-victory.jpg",
      "http://i.imgur.com/lmmBt.gif",
      "http://danceswithfat.files.wordpress.com/2011/08/victory.jpg",
      "http://stuffpoint.com/family-guy/image/56246-family-guy-victory-is-his.gif",
      "http://thelavisshow.files.wordpress.com/2012/06/victorya.jpg",
      "http://alookintomymind.files.wordpress.com/2012/05/victory.jpg",
      "http://rack.3.mshcdn.com/media/ZgkyMDEzLzA4LzA1L2QwL2JyYWRwaXR0LmJjMmQyLmdpZgpwCXRodW1iCTg1MHg1OTA-CmUJanBn/1a5a0c57/968/brad-pitt.jpg",
      "http://rack.0.mshcdn.com/media/ZgkyMDEzLzA4LzA1L2ViL2hpZ2hzY2hvb2xtLjI4YjJhLmdpZgpwCXRodW1iCTg1MHg1OTA-CmUJanBn/4755556e/b82/high-school-musical-victory.jpg",
      "http://rack.2.mshcdn.com/media/ZgkyMDEzLzA4LzA1L2ZkL25hcG9sZW9uZHluLjBiMTFlLmdpZgpwCXRodW1iCTg1MHg1OTA-CmUJanBn/8767246f/d7a/napoleon-dynamite.jpg",
      "http://rack.0.mshcdn.com/media/ZgkyMDEzLzA4LzA1L2RiL3RvbWZlbGRvbi41NmRjNi5naWYKcAl0aHVtYgk4NTB4NTkwPgplCWpwZw/05cd12cc/645/tom-feldon.jpg",
      "http://rack.3.mshcdn.com/media/ZgkyMDEzLzA4LzA1L2JmL2hpbXltLjU4YTEyLmdpZgpwCXRodW1iCTg1MHg1OTA-CmUJanBn/90a990f6/b38/himym.jpg",
      "http://rack.3.mshcdn.com/media/ZgkyMDEzLzA4LzA1L2U1L2NvbGJlcnRyZXBvLjVjNmYxLmdpZgpwCXRodW1iCTg1MHg1OTA-CmUJanBn/710824a0/764/colbert-report.jpg",
      "http://rack.1.mshcdn.com/media/ZgkyMDEzLzA4LzA1LzYyL2FuY2hvcm1hbi42NjJkYS5naWYKcAl0aHVtYgk4NTB4NTkwPgplCWpwZw/009ee80f/1c0/anchorman.jpg",
      "http://rack.3.mshcdn.com/media/ZgkyMDEzLzA4LzA1LzFmL2hhcnJ5cG90dGVyLjYxNjYzLmdpZgpwCXRodW1iCTg1MHg1OTA-CmUJanBn/db79fc85/147/harry-potter.jpg"
    ]
    r.reply bot.random vic

  bot.regexp /^\.gif (.+)/, ".gif <query> -- Prikaže naključni gif", (match, r) ->
      url = "http://giphy.com/search/#{encodeURI(match[1].replace(/[^a-z0-9\s]/g,"").replace(/\s\s+/g, "-"))}"
      bot.fetchHTML url.replace(/%20/g, '-'), ($) ->
        count = $("#searchresults .found-count").text().split(" GIFs found for")
        if count[0] > 0
          gif_id = $(".hoverable-gif a").eq(0).attr("data-id")
          r.reply "http://media.giphy.com/media/#{gif_id}/giphy.gif"
        else
          r.reply "No gif available :("

  bot.command /^((give me|spread) some )?(joy|love)( asshole)?/i, (r) ->
    bot.fetchHTML 'http://thecodinglove.com/random', ($) ->
      img_src = $("#post1 > div.bodytype > p > img").first().attr('src')
      txt = $("#post1 > div.centre > h3 > a").first().text()
      txt = txt.replace(/[\n\r]/g, '')
      r.reply "#{txt} #{img_src}"

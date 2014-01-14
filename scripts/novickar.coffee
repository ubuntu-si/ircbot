Twitter = require './lib/stream-tw'

sledi = [
  "BBCBreaking"
  "wired"
  "cnnbrk"
  "hackerSi"
  "BreakingNews"
  "radiostudent"
  "24ur_com"
  "rtvslo"
  "HNTweets"
  "mashsocialmedia"
]

get_ids = (cb)->
  oauth =
    consumer_key: process.env.T_CK
    consumer_secret: process.env.T_CS
    token: process.env.T_ATK
    token_secret: process.env.T_ATS
  request.get
    url: "https://api.twitter.com/1.1/users/lookup.json?screen_name=#{sledi.join(",")}"
    oauth: oauth
    json: true
  , (e, r, data) ->
    console.log data
    console.log e
    ids = []
    for u in data
      ids.push u.id_str
    console.log "Sledim: #{ids}"
    cb ids
    
replace_urls = (text, entities) ->
  for u in entities
    text = text.replace u.url, u.expanded_url
  return text

module.exports = (bot) ->
  get_ids (ids) ->
    stream = new Twitter
      consumer_key: process.env.T_CK
      consumer_secret: process.env.T_CS
      access_token_key: process.env.T_ATK
      access_token_secret: process.env.T_ATS
      follow: ids

    stream.stream()
    stream.on "error", (e)->
      console.log e

    stream.on "data", (tweet)->
      try
        unless tweet.retweeted_status or tweet.in_reply_to_screen_name or (/^RT/.test tweet.text)
          text = replace_urls tweet.text, tweet.entities.urls
          text = "[#{tweet.user.screen_name}] " + text
          redis.smembers("irc:novickar").then (nicks)->
            if nicks?   
              for nick in nicks
                bot.say text, nick
      catch e
        console.log e
    
  bot.command /^\.naroči$/i,
    ".naroči -- Prijavi se na novice (#{sledi.join(",")})",
    (r) ->
      redis.sadd("irc:novickar", r.nick).then (status)->
        r.privmsg "Naročen na novice #{!status?'OK':status}"
        redis.smembers("irc:novickar").then (nicks)->
          console.log "Naročeni: #{nicks}"

  bot.command /^\.odjavi$/i,
    ".odjavi -- Odjavi se od novic (#{sledi.join(",")})",
    (r) ->
      redis.srem("irc:novickar", r.nick).then (status)->
        r.privmsg "Odjavljen od novic #{!status?'OK':status}"
        redis.smembers("irc:novickar").then (nicks)->
          console.log "Naročeni: #{nicks}"

parser = require 'parse-rss'

module.exports = (bot) ->
  url = "https://wordpress.org/news/category/releases/feed/"
  interval = 1000 * 60 * 60 * 1     # interval is in ms so 1000 * 60 * 60  is 1 hr
  published = 0     # 0 = no msg has been sent, 1 = msg has been sent

  do wpCheck = ->
    today = new Date
    sleep = ->
      parser url, (err,rss)->
        console.log err if err
        pubDate = new Date(rss[0].pubDate)
        if pubDate.getMonth() == today.getMonth() && pubDate.getDate() == today.getDate() && published == 0
          if 'Security' in rss[0].categories
            bot.say "URGENT! #{rss[0].title} is available! Read more at  #{rss[0].link}\nPublished: #{rss[0].date}", "#ubuntu-si"
            published = 1
          else
            bot.say "Sweet! #{rss[0].title} is available! Read more at #{rss[0].link}\nPublished: #{rss[0].date}", "#ubuntu-si"
            published = 1
        #we should reset our published variable otherwise we will only see msg about release/critical fix once and in order we do not spam the channel multiple times a day we reset
        # it on a day that differs from pubDate
        if pubDate.getMonth() == today.getMonth() && pubDate.getDate() != today.getDate()
          published = 0
    #we should sleep 20s because we can't post our msg on bot startup since we are still not connected to the irc server
    setTimeout sleep, 20000

  setTimeout wpCheck, interval

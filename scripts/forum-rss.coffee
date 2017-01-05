# Description:
#   RSS feed alerter
#
# Dependencies:
#   "nodepie": "0.5.0"
#
# Configuration:
#   HUBOT_ALERTS_RSS_FEED - URL of the feed
#   HUBOT_ALERTS_RSS_ANNOUNCE_ROOM - where should Hubot announce new feed items
#   HUBOT_ALERTS_RSS_INTERVAL - how often (in seconds) to check the RSS feed - default: 300 (5 minutes)
#   HUBOT_ALERTS_RSS_PREPEND - text to prepend to alert messages - default: "RSS Alert"
#   HUBOT_ALERTS_RSS_BROKEN_TZ_ADJUSTMENT - if a feed's timezone is broken set this to adjust it - default: 0
#   HUBOT_ALERTS_RSS_SKIP_FIRST - skip any items when first checking the feed - default: true (set to false for debugging)
#
# Commands:
#   none
#
# Author:
#   larcher
# Modified:
#   ubuntu-si 

NodePie = require("nodepie")

# grab settings from environment variables, with defaults
feed_url          = "https://www.ubuntu.si/forum/discussions/comments/all/feed.rss"
rss_interval      = 60
broken_tz_adjust  = 0
skip_first_string = "true"
skip_first = (skip_first_string == "true")

if skip_first
    # effectively "mark all as read" when we start up
    last_check_time = (new Date()).getTime()
else
    last_check_time = 0

module.exports = (bot) ->
  parse_feed = (err,res,body) ->
    if res.statusCode is not 200
      console.log "Error retrieving feed - status: " + res.statusCode
    else
      feed = new NodePie(body)
      try
        feed.init()
        return feed
      catch e
        console.log "Problem parsing feed", e
    return false

  check_feed = (bot) ->
    # console.log "Checking alerts feed .. " + (new Date())
    bot.fetch feed_url , (err,res,body) ->
      now = (new Date())
      feed = parse_feed(err,res,body)
      if feed
        latest = feed.getItems(0,1)[0]
        if latest
          latest_date = latest.getUpdateDate()
          latest_date.setTime( latest_date.getTime() + (60*60*1000*broken_tz_adjust))
          if (latest_date - last_check_time ) >= 0
            result = "[forum] " + latest.getAuthor() + " " + latest.getTitle() + " -- " + latest.getPermalink()
            if !result
              console.log "Something failed: "+ result
            else
              bot.say result, "#ubuntu-si"
        last_check_time = now

  setInterval( check_feed, rss_interval*1000, bot)

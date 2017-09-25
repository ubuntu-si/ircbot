module.exports = (bot) ->

  resolve = (url, cb)->
    bot.fetchHTML url, ($)->
      if $
        stack = []
        stack.push $("title").eq(0).text().replace(/\s\s+/g, "").replace(/&nbsp;/g,"").replace(/\n/g, "")
        opis = $("meta[name=description]").attr("content")
        if opis
          stack.push opis.replace(/\s\s+/g, "").replace(/&nbsp;/g,"").replace(/\n/g, "")
        cb stack.join("\n")

  bot.on 'user:talk', (r) ->
    is_url = /(?:.+)?(https?:\/\/[\S]+)(?:.+)?/ig;
    url = is_url.exec(r.text)
    if url
      msg = "#{r.text} @#{moment().toString()}"
      redis.rpush("irc:zgodovina:#{r.nick}", msg)
      resolve url[1], r.reply

  bot.regexp /^\.url (.+)/i,
    ".url <nick> Prikaži urlje, ki jih je objavil <nick>"
    (match, r) ->
      nick = match[1]
      redis.lrange("irc:zgodovina:#{nick}", -5, 5).then (data)->
        for msg in data
          r.reply msg
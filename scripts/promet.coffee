module.exports = (bot) ->

  bot.command /^\.promet/i,
    ".promet Izpi�e povezavo do zemljevida prometnih razmer"
    (r) ->
      r.reply "Razmere v prometu: http://www.promet.si/portal/map/portal.aspx"
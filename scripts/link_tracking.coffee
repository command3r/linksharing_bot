module.exports = (robot) ->
  brain_key = "link_tracking"
  data = {}
  robot.brain.on('loaded', (_brain_data) ->
    data = robot.brain.get(brain_key) || {}
  )

  trackUrl = (user, room, url) ->
    payload = [user, url, Date.now()]
    data[room] ||= []
    data[room].unshift(payload)

    robot.brain.set(brain_key, data)

  robot.hear /(https?:\/\/[^ ]+)/i, (msg) ->
    matches = msg.match
    url = matches[1]
    user = msg.message.user.name.toLowerCase()
    room = msg.message.room

    trackUrl(user, room, url)

  robot.respond /(show )?latest links/, (msg) ->
    msg.send(
      if data[msg.message.room]?
        list = data[msg.message.room].slice(0, 5).map ([user, url, time]) ->
          date = new Date(time)
          date = "#{date.getMonth() + 1}/#{date.getDate()} #{date.getHours()}:#{date.getMinutes()}"
          "#{url} by #{user}, #{date}"
        "Latest links:\n\n#{list.join("\n")}"
      else
        "No links yet."
    )

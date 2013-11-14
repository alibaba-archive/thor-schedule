schedule = require('../index').initialize({
  req: 'tcp://localhost:5567'
  sub: 'tcp://localhost:5568'
})

now = Date.now()
schedule.schedule
  schedule: now + 1000
  callback: ->
    process.send(process.pid)
    process.exit()

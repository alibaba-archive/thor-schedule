Thor-Schedule
======
Schedule client for [thorbuster](https://github.com/teambition/thorbuster) service

# Example

## initialize
```coffeescript
schedule = require('thor-schedule').initialize({
  req: 'tcp://localhost:5567'
  sub: 'tcp://localhost:5568'
  debug: true
})
```

## schedule
```coffeescript
schedule.schedule
  schedule: Date.now() + 1000
  callbackData: {msg: 'I will be back'}
  callback: (data) ->
    console.log data.msg
==> 'I will be back'
```

## cancel
```coffeescript
schedule.schedule
  schedule: Date.now() + 1000
  taskId: 'sometitle'
  callback: ->
    console.log 'You will never see this message'

schedule.cancel({taskId: 'sometitle'})
```

# Licence
MIT

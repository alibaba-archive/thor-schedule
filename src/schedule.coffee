zmq = require('zmq')
crypto = require('crypto')

class Schedule

  requester = null
  subscriber = null
  initialized = false
  tasks = {}
  clientId = process.pid.toString()
  clientLen = clientId.length

  initialize: (options) ->
    unless initialized
      {req, sub, debug} = options
      throw new Error("req and sub could not be empty!") unless req? and sub?
      requester = zmq.socket('req')
      subscriber = zmq.socket('sub')

      requester.connect(req)
      subscriber.connect(sub)

      subscriber.on 'message', (msg) ->
        msg = msg[clientLen..]
        console.log new Date, msg.toString() if debug
        try
          task = JSON.parse(msg)
        catch e
          return false
        if task.callbackId? and tasks[task.callbackId]?
          tasks[task.callbackId](task.callbackData or {})

      subscriber.subscribe(clientId)
      initialized = true
    return this

  ###
  Schedule async tasks
  @schedule `Date` `required` Schedule date string or timestamp
  @callback `Mixed` `required` Callback function
  @callbackData `Mixed` `optional` Callback data
  @taskId `String` `optional` Task identify; without this property, cancel will not work
  @callbackId `String` `optional` Specific callback id
  @jobs `Mixed` `optional` Run jobs on thorbuster process; Must be pre-defined on thorbuster
  ###
  schedule: (data = {}) ->
    {callback, callbackData} = data
    callbackData ?= {}
    unless initialized
      return callback(callbackData) if callback?
    data.callbackId ?= @sha1(callback) if callback?
    data.clientId = clientId
    delete data.callback
    requester.send(JSON.stringify(data))

    tasks[data.callbackId] = callback

  ###
  Cancel scheduled tasks
  @taskId `String` `required` Task identify
  ###
  cancel: (data) ->
    return false unless data.taskId?
    _data =
      taskId: data.taskId
      jobs: ['cancel']
      schedule: new Date()
    requester.send(JSON.stringify(_data))

  sha1: (any) ->
    crypto.createHash('md5').update(any.toString()).digest('hex')

schedule = new Schedule
schedule.Schedule = Schedule
module.exports = schedule

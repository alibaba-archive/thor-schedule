should = require('should')
{fork} = require('child_process')
schedule = require('../index').initialize({
  req: 'tcp://localhost:5567'
  sub: 'tcp://localhost:5568'
  debug: true
})

describe 'thor#schedule', ->

  @timeout(5000)

  it 'should callback in 1 seconds', (done) ->
    now = Date.now()
    msg = 'I will be back'
    schedule.schedule
      schedule: now + 1000
      callback: (data) ->
        duration = Date.now() - now
        duration.should.be.within(1000, 1100)
        data.msg.should.eql(msg)
        done()
      callbackData: {msg: msg}

  it 'should be canceled in 500 milliseconds', (done) ->
    now = Date.now()
    taskId = Math.round(Math.random() * 100000)
    schedule.schedule
      schedule: now + 1000
      callback: ->
        done('oh no! I am not be canceled!')
      taskId: taskId

    setTimeout (->
      schedule.cancel({taskId: taskId})
      ), 500

    setTimeout(done, 2000)

  it 'should be rescheduled to 2 seconds', (done) ->
    now = Date.now()
    taskId = Math.round(Math.random() * 100000)
    schedule.schedule
      schedule: now + 1000
      taskId: taskId
      callback: ->
        duration = Date.now() - now
        duration.should.be.within(2000, 2100)
        done()

    schedule.schedule
      schedule: now + 2000
      taskId: taskId

  it 'should not disturb each other on different tasks', (done) ->
    now = Date.now()
    task1Finished = false
    task2Finished = false
    _callback = ->
      if task1Finished and task2Finished
        duration = Date.now() - now
        duration.should.be.within(1000, 1100)
        done()

    schedule.schedule
      schedule: now + 1000
      callback: ->
        task1Finished = true
        _callback()

    schedule.schedule
      schedule: now + 1000
      callback: ->
        task2Finished = true
        _callback()

  it 'should not disturb each other on different clients', (done) ->
    pids = []
    total = 10
    _done = ->
      total -= 1
      done() if total < 1
    for i in [0...total]
      do ->
        child = fork("#{__dirname}/child.coffee")
        child.on 'message', (pid) ->
          pids.should.not.include(pid)
          pids.push(pid)
          _done()

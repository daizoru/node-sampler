Sampler = require '../lib/sampler'
{log,error,inspect} = require 'util'
delay = (t,f) -> setTimeout f, t

TIMEOUT = 10 # 100 milliseconds

# these are not real tests, it's more like a demo
# more complete tests should check for returned values!!!

events = [
  {companyhelpdesk: "hi how can I help you"}
  {facebook: "wow! this was a big earthquake"}
  {twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"}
  {twitter: "ZOMBIE APOCALYPSE!!1!!"}
]
scheduleEvents = (sampler, i=0) ->
  total = 0
  for event in events
    total += Math.random() * 100
    delay Math.round(total), ->
      sampler.rec event
  total

# our tests
describe 'Sampler', ->
  describe '#rec()', ->
    it 'should record', (done) ->
      sampler = new Sampler()
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"
      sampler.on 'end', -> done()
      testDelay = scheduleEvents sampler
      verificationDelay = testDelay + TIMEOUT
      @timeout verificationDelay + TIMEOUT
      delay verificationDelay, -> done()

  describe '#play(rate=1.0)', ->
    it 'should support default rate', (done) ->
      sampler = new Sampler()
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"
      sampler.on 'end', -> done()
      testDelay = scheduleEvents sampler
      verificationDelay = testDelay + TIMEOUT
      @timeout verificationDelay + testDelay + TIMEOUT
      delay verificationDelay, => 
        sampler.play()

    it 'should support 4.0x rate', (done) ->
      sampler = new Sampler()
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"
      sampler.on 'end', -> done()
      testDelay = scheduleEvents sampler
      verificationDelay = testDelay + TIMEOUT
      @timeout verificationDelay + (testDelay / 4.0) + TIMEOUT
      delay verificationDelay, => 
        sampler.play 4.0

    it 'should support 0.15x rate', (done) ->
      sampler = new Sampler()
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"
      sampler.on 'end', -> done()
      testDelay = scheduleEvents sampler
      verificationDelay = testDelay + TIMEOUT
      @timeout verificationDelay + (testDelay / 0.15) + TIMEOUT
      delay verificationDelay, => 
        sampler.play 0.15



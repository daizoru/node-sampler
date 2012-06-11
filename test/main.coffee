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
scheduleEvents = (sampler) ->
  total = 0
  for event in events
    # events occurs every 50~150ms
    total += 50 + Math.random() * 150
    delay Math.round(total), ->
      sampler.rec event
  total


# our tests
describe 'Sampler', ->

  sampler = new Sampler()
  duration = 0

  describe '#rec()', ->
    it 'should record', (done) ->
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"

      duration = scheduleEvents(sampler)
      #log "duration: #{duration}"
      timeout = duration + TIMEOUT
      @timeout timeout
      delay duration, -> done()

  describe '#play(rate=1.0)', ->
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (duration / 1.0)
      sampler.play -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (duration / 2.0)
      sampler.play 2.0, -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (duration / 10.0)
      sampler.play 10.0, -> done()

    it 'playback at 0.10x speed', (done) ->
      @timeout TIMEOUT + (duration / 0.10)
      sampler.play 0.10, -> done()
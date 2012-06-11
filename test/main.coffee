Sampler = require '../lib/sampler'
{log,error,inspect} = require 'util'
events = require 'events'

delay = (t,f) -> setTimeout f, t

class Newsfeed extends events.EventEmitter
  constructor: ->
    @events = [
      { companyhelpdesk: "hi how can I help you" }
      { facebook: "wow! this was a big earthquake" }
      { ticker: -3234 }
      { weatherstation: {temp:"76", unit:"F"} }
      { counter: 42 }
      { irc: {channel:"#FOO",msg:"<bar> ho hai"} }
      { twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out" }
      { twitter: "ZOMBIE APOCALYPSE!!1!!" }
    ]

  startSendingTo: (sampler) =>
    total = 0
    for event in @events
      # events occurs every 50~100ms
      total += 50 + Math.random() * 50
      delay Math.round(total), ->
        sampler.rec event
    total

  startFeed: (key='event') =>
    total = 0
    for event in @events
      # events occurs every 50~100ms
      total += 50 + Math.random() * 50
      delay Math.round(total), =>
        @emit key, Math.round(Math.random()), event
    total


TIMEOUT = 10 # 100 milliseconds

# these are not real tests, it's more like a demo
# more complete tests should check for returned values!!!


scheduleEvents = (sampler) ->


# our tests
describe 'Sampler - direct mode', ->

  sampler = new Sampler()
  feed = new Newsfeed()
  duration = 0

  describe '#rec()', ->
    it 'should record 8 events (1 every 50~100ms)', (done) ->
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"

      duration = feed.startSendingTo sampler
      #log "duration: #{duration}"
      timeout = duration + TIMEOUT
      @timeout timeout
      delay duration, -> done()

  describe '#play()', ->
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (duration / 1.0)
      sampler.play -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (duration / 2.0)
      sampler.play 2.0, -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (duration / 10.0)
      sampler.play 10.0, -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (duration / 0.345)
      sampler.play 0.345, -> done()


# our tests
describe 'Sampler - async/event mode', ->

  sampler = new Sampler()
  feed = new Newsfeed()

  sampler.listen feed
  
  duration = 0

  describe '#rec()', ->
    it 'should record 8 events (1 every 50~100ms)', (done) ->
      sampler.on 'event', (event) -> #log "#{event.timestamp}: #{inspect event.data}"

      duration = feed.startFeed 'data'

      #log "duration: #{duration}"
      timeout = duration + TIMEOUT
      @timeout timeout
      delay duration, -> done()

  describe '#play()', ->
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (duration / 1.0)
      sampler.play -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (duration / 2.0)
      sampler.play 2.0, -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (duration / 10.0)
      sampler.play 10.0, -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (duration / 0.345)
      sampler.play 0.345, -> done()
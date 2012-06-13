
# Standard Node Library
{log,error,inspect} = require 'util'
{Stream} = require 'stream'

# helper functions from our app
{delay} = require '../lib/misc/toolbox'

# The API we want to stress
{Record,simple,stream} = require '../lib/sampler'

class Newsfeed extends Stream
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

  # Simple API
  map: (cb) =>
    total = 0
    @events.push no
    for event in @events
      # events occurs every 50~100ms
      total += 50 + Math.random() * 50
      delay Math.round(total), -> cb event
    return

  # Stream API
  start: =>
    @map (event) =>
      if event
        @emit 'data', event
      else
        @emit 'end', {}
 
feed = new Newsfeed() # unique data source used for all tests
TIMEOUT = 10 # 10 milliseconds

# our tests
describe 'Simple API', ->

  record = new Record()

  describe '#rec()', ->
    it 'should record 8 events (1 every 50~100ms)', (done) ->
      @timeout 3000 # TODO use something better here
      recorder = new simple.Recorder record
      feed.map (event) ->
        if event
          recorder.rec event
        else
          done()

  describe '#play()', ->
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (record.duration / 1.0)
      player = new simple.Player record, onEnd: -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (record.duration / 2.0)
      player = new simple.Player record,
        rate: 2.0
        onEnd: -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (record.duration / 10.0)
      player = new simple.Player record,
        rate: 10.0
        onEnd: -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (record.duration / 0.345)
      player = new simple.Player record,
        rate: 0.345
        onEnd: -> done()


# our tests
describe 'Stream API', ->

  # create a new record, this one will be stream written!
  record = new Record()
  
  describe '#rec()', ->
    it 'should record 8 events (1 every 50~100ms)', (done) ->
      @timeout 3000
      feed.on 'end', -> done()
      feed.start()

  describe '#play()', ->
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (record.duration / 1.0)
      record.play -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (record.duration / 2.0)
      record.play 2.0, -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (record.duration / 10.0)
      record.play 10.0, -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (record.duration / 0.345)
      record.play 0.345, -> done()
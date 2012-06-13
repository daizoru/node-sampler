
# Standard Node Library
{log,error,inspect} = require 'util'
{Stream} = require 'stream'

# helper functions from our app
{delay} = require '../lib/misc/toolbox'

# The API we want to stress
{Record,SimplePlayer,SimpleRecorder,StreamPlayer,StreamRecorder} = require '../lib/sampler'

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
  pipe: (destination) =>
    destination
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
      recorder = new SimpleRecorder record
      feed.map (event) -> if event then recorder.write(event) else done()

  describe '#play()', ->
    length = record.length()
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (length / 1.0)
      new SimplePlayer record, 
        onEnd: -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (length / 2.0)
       new SimplePlayer record,
        rate: 2.0
        onEnd: -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (length / 10.0)
      new SimplePlayer record,
        rate: 10.0
        onEnd: -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (length / 0.345)
       new SimplePlayer record,
        rate: 0.345
        onEnd: -> done()


# our tests
describe 'Stream API', ->

  # create a new record, this one will be stream written!
  record = new Record()
  
  describe '#stream.Recorder()', ->
    it 'should record 8 events (1 every 50~100ms)', (done) ->
      @timeout 3000
      feed.on 'end', -> done()
      recorder = new StreamRecorder history
      feed.pipe(recorder)

  describe '#play()', ->
    length = record.length()
    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (length / 1.0)
      player = new StreamPlayer history
      player.on 'end', -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (length / 2.0)
      player = new StreamPlayer history, rate: 2.0
      player.on 'end', -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (length / 10.0)
      player = new StreamPlayer history, rate: 10.0
      player.on 'end', -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (length / 0.345)
      player = new StreamPlayer history, rate: 0.345
      player.on 'end', -> done()
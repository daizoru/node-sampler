
# Standard Node Library
{log,error,inspect} = require 'util'
{Stream} = require 'stream'
moment = require 'moment'

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

  resume: (cb=no) =>

    run = (remainingItems, cb) =>
      event = remainingItems[0]
      remainingItems = remainingItems[1..]
      if event
        if cb 
          cb event
        else
          @emit 'data', event

      if (remainingItems.length is 0) or (!event)
        if cb
          cb()
        else
          @emit 'end'
        return

      delay (50+Math.random(50)), =>
        run remainingItems, cb
    run @events, cb


TIMEOUT = 50 # 10 milliseconds

# our tests
describe 'new Record(\'test.sample\')', ->
  # our tests
  describe 'and Simple API', ->

    record = new Record 'file://test.sample'
    length = 0
    it 'record some events in about 100ms', (done) ->
      #@timeout 10000
      recorder = new SimpleRecorder record
      feed = new Newsfeed()
      feed.resume (event) -> 
        if event
          recorder.write event
        else
          length = record.length()
          done()

    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (length / 1.0)
      new SimplePlayer record, onEnd: -> done()

###


# our tests
describe 'new Record()', ->
  # our tests
  describe 'and Simple API', ->

    record = new Record()
    length = 0
    it 'record some events in about 100ms', (done) ->
      #@timeout 10000
      recorder = new SimpleRecorder record
      feed = new Newsfeed()
      feed.resume (event) -> 
        if event
          recorder.write event
        else
          length = record.length()
          done()

    it 'playback at normal speed', (done) ->
      @timeout TIMEOUT + (length / 1.0)
      new SimplePlayer record, onEnd: -> done()

    it 'playback at 2.0x speed', (done) ->
      @timeout TIMEOUT + (length / 2.0)
      new SimplePlayer record,
        speed: 2.0
        onEnd: -> done()

    it 'playback at 10.0x speed', (done) ->
      @timeout TIMEOUT + (length / 10.0)
      new SimplePlayer record,
        speed: 10.0
        onEnd: -> done()

    it 'playback at 0.345x speed', (done) ->
      @timeout TIMEOUT + (length / 0.345)
      new SimplePlayer record,
        speed: 0.345
        onEnd: -> done()

# our tests
describe 'Stream API', ->

  # create a new record, this one will be stream written!

  record = new Record()
  length = 0

  it 'should record some events in about 100ms', (done) ->
    #@timeout 3000

    feed = new Newsfeed() # unique data source used for all tests
    feed.on 'end', -> 
      length = record.length()
      log "length #{length}"
      done()
    recorder = new StreamRecorder record
    feed.pipe(recorder)
    feed.resume()

###

###
  it 'playback at normal speed', (done) ->
    @timeout TIMEOUT + (length / 1.0)
    player = new StreamPlayer record
    player.on 'end', -> done()

  it 'playback at 2.0x speed', (done) ->
    @timeout TIMEOUT + (length / 2.0)
    player = new StreamPlayer record, speed: 2.0
    player.on 'end', -> done()

  it 'playback at 10.0x speed', (done) ->
    @timeout TIMEOUT + (length / 10.0)
    player = new StreamPlayer record, speed: 10.0
    player.on 'end', -> done()

  it 'playback at 0.345x speed', (done) ->
    @timeout TIMEOUT + (length / 0.345)
    player = new StreamPlayer record, speed: 0.345
    player.on 'end', -> done()
###
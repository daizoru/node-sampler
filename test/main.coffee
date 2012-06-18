
# Standard Node Library
{log,error,inspect} = require 'util'
{Stream} = require 'stream'
fs = require 'fs'

# thirs party libs
moment = require 'moment'

# helper functions from our app
{delay} = require '../lib/misc/toolbox'

# The API we want to stress
{Record,SimplePlayer,SimpleRecorder,StreamPlayer,StreamRecorder} = require '../lib/sampler'

# read this: http://www.slideshare.net/atcrabtree/functional-programming-with-streams-in-nodejs

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

    @readable = yes
    @resumed = no


  # resume will be called whenever a 'drain' event is emitted by the writeableStream
  resume: =>
    #log "Newsfeed: resume"
    unless @resumed
      @resumed = yes
      @run @events

  run: (remainingItems, cb=no) =>
    #log "run(remainingItems size: #{remainingItems.length}))"
    event = remainingItems[0]
    remainingItems = remainingItems[1..]
    if event
      if cb 
        cb event
      else
        #log "CALLING EMIT 'data', event"
        @emit 'data', event

    if (remainingItems.length is 0) or (!event)
      #log "LATEST DONE.. CALLING CB"
      if cb
        #log "CALLING CB()"
        cb()
      else
        #log "CALLING EMIT 'END'"
        @emit 'end'
        @emit 'close'
      return
    t = (50+Math.random(50))
    delay t, =>
      @run remainingItems, cb

  runFirst: (cb=no) =>
    #log "runFirst"
    @run @events, cb


TIMEOUT = 50 # Not good, we have a latency of 50~60ms


# our tests
describe 'new Record(\'test/tmp.json\')', ->
  # our tests
  describe 'using Simple API', ->

    fs.unlink 'test/tmp.json', (err) ->
      unless err
        #log "removed previous test file"
        0
      record = new Record 'file://test/tmp.json'
      length = 0

      it 'should record some events in about 100ms', (done) ->
        #@timeout 10000
        recorder = new SimpleRecorder record
        feed = new Newsfeed()

        t = moment()
        feed.runFirst (event) -> 
          e = moment() - t

          #log "runFirst (event): elapsed: #{e}"

          if event
            #log "event"
            recorder.write event
          else
            length = record.length()
            #log "ENDED RECORD. length: #{length}"
            recorder.close()
            done()

      it 'should playback at normal speed', (done) ->
        t = moment()
        new SimplePlayer record, 
          onBegin: =>
            #log "stream started. timeout set to 30 + #{TIMEOUT + (length / 1.0)}"
            @timeout (30 + TIMEOUT + (length / 1.0))
          onEnd: => 
            e = moment() - t
            #log "play expected: 30 + #{TIMEOUT + (length / 1.0)}; elapsed: #{e}"
            done()

      it 'should load an existing demo file', (done) ->
        t = moment()
        record = new Record "file://test/test.json"
        new SimplePlayer record, 
          onBegin: =>
            #log "stream started. timeout set to 30 + #{TIMEOUT + (length / 1.0)}"
            @timeout (30 + TIMEOUT + (record.length() / 1.0))
          onEnd: => 
            e = moment() - t
            #log "play expected: 30 + #{TIMEOUT + (length / 1.0)}; elapsed: #{e}"
            done()

# our tests
describe 'new Record()', ->
  # our tests
  describe 'and Simple API', ->

    record = new Record()
    length = 0
    it 'record some events in about 100ms', (done) ->
      recorder = new SimpleRecorder record
      feed = new Newsfeed()
      feed.runFirst (event) -> 
        if event
          recorder.write event
        else
          length = record.length()
          recorder.close()
          done()

    it 'playback at normal speed', (done) ->
      new SimplePlayer record, 
        onBegin:  =>  @timeout 70 + (length / 1.0)
        onEnd:    -> done()

    it 'playback at 2.0x speed', (done) ->

      new SimplePlayer record,
        speed: 2.0
        onBegin: => @timeout 40 + (length / 2.0)
        onEnd:   -> done()

    # looks like increasing speed reduce latency... WTF?
    # maybe this is bacause of the latency reduction
    it 'playback at 10.0x speed', (done) ->
      new SimplePlayer record,
        speed: 10.0
        onBegin: => @timeout 20 + (length / 10.0)
        onEnd: -> done()

    it 'playback at 0.345x speed', (done) ->
      #log "timeout set to 160 + #{(length / 0.345)}"
      t = moment()
      new SimplePlayer record,
        speed: 0.345
        onBegin: =>
          @timeout 170 + (length / 0.345)
        onEnd: -> 
          #log "ELAPSED: #{moment() - t}"
          done()

# our tests
describe 'Stream API', ->

  # create a new record, this one will be stream written!

  record = new Record()
  length = 0

  it 'should record some events in about 100ms', (done) ->
    feed = new Newsfeed()
    recorder = new StreamRecorder record
    feed.pipe recorder
    feed.resume()

    # also intercept the 'end' event, to close the unit test
    feed.on 'end', -> 
      length = record.length()
      #log "length #{length}"
      done()

  it 'playback events at normal speed', (done) ->
    @timeout 70 + (length / 1.0)
    player = new StreamPlayer record
    player.on 'data', (event) -> throw "error, got a timestamp" if event.timestamp?
    player.on 'end', -> done()

  it 'playback timestamped events at normal speed', (done) ->
    @timeout 70 + (length / 1.0)
    player = new StreamPlayer record,
      withTimestamp: yes
    player.on 'data', (event) -> throw "error, no timestamp" unless event.timestamp?
    player.on 'end', -> done()

  it 'playback at 2.0x speed', (done) ->
    @timeout 40 + (length / 2.0)
    player = new StreamPlayer record, speed: 2.0
    player.on 'end', -> done()

  it 'playback at 10.0x speed', (done) ->
    @timeout 20 + (length / 10.0)
    player = new StreamPlayer record, speed: 10.0
    player.on 'end', -> done()


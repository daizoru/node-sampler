# node-sampler

 A library which record things and play them back

## Overview

 Record byte streams/events (eg. twitter, music, IRC, Apache logs..) and play them back (eg. to test or debug an app, reproduce errors, simulate events)

 One the of main features is that you can control the speed speed, 
 very useful to train machine learning algorithms on historic data (eg. Twitter streams)

### Current status

  This library is still in development so expect heavy refactoring and sparse documentation until I have more time to settle everything.

### Features

  * control the playback speed (slower or faster)
  * accuspeed scheduler (latency if automatically correct)

### TODO / Wishlist
  
  * support the Stream API (for the moment it is only a basic EventEmitter)
  * save/export samples (to databases, files..)
  * load/import samples (from APIs, databases, CSVs..)
  * insertion of event at arbitrary timesteps (eg. when working with incomplete time-series)
  * reverse playback?
  * more tests

### License

  BSD

## Installation

### For users

#### Install it as a dependency for your project

    $ npm install sampler

#### Install it globally in your system

    $ npm install sampler -g

#### Run the tests

    $ npm run-script test

### For developers

  To install node-sampler in a development setup:

    $ git clone http://github.com/daizoru/node-sampler.git
    $ cd node-sampler
    $ npm link
    $ # optional:
    $ # npm run-script test 

  To build the coffee-script:

    $ npm run-script build


## Documentation

  Sampler has two differents APIs: one for classic, quick & dirty code (Simple API),
  the second for cleaner, async streamlined code (Stream API)

### Simple API

Recording

``` coffeescript

{Record, SimpleRecorder} = require 'sampler'

# create record. a record is where your events are stored
record = new Record() # by default no arguments -> in memory store

# now, you can start playing with your record. 
# let's record things in the record! for this, you need a Recorder
recorder = new SimpleRecorder(record)

# then just write things inside
recorder.write "hello"
recorder.write foo: "hello", bar: "world"
recorder.write new Buffer()

# in the future, you will be able to add an event at a specific time
# recorder.writeAt moment(1982,1,1), "cold wave"

```

Playback

``` coffeescript

{Record, SimplePlayer} = require 'sampler'

# load an existing record - for the moment.. nothing is supported :) only in-memory
# but in the future, you will be able to load MongoDB, SQL, Redis records etc..
record = new Record("redis://foobar")

# now, you can start playing with your record. 
# let's record things in the record! for this, you need a Player
player = new SimplePlayer(record)

# by default the player start itself automatically

```

  To be continued

### Recording external inputs

  Eg. to record the twitter stream

``` coffeescript

# standard node library
{log,inspect}   = require 'util'

# third-parties libraries
Twitter = require 'ntwitter'
moment = require 'moment'

# sampler modules
sampler = require '../lib/sampler'
delay = (t, f) -> setTimeout f, t

# PARAMETERS
duration = 5
timeline = new sampler.Record()
twit = new Twitter
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token_key: process.env.TWITTER_TOKEN_KEY
  access_token_secret: process.env.TWITTER_TOKEN_SECRET


# let's open a stream on random tweets
twit.stream 'statuses/sample', (stream) ->
  recorder = new sampler.SimpleRecorder timeline
  stream.on 'error', (err) ->
    log "twitter error: #{inspect err}"
  stream.on 'data', (data) -> 
    timeline.write moment(data.created_at), data.text
  delay duration*1000, ->
    log "playing tweets back"
    new sampler.SimplePlayer timeline,
      speed: 2.0
      onData: (tm, data) ->
        log "#{tm}: #{inspect data}"
      onEnd: ->
        process.exit()
  log "listening for #{duration} seconds"

```


## Changelog

### 0.0.2

 * REFACTORED EVERYTHING WITH FIRE

### 0.0.1

 I Added a callback when the playback reach the end:
 
``` javascript

  sampler.on("end", function() {
    console.log("playback terminated")
  })
  
```

### 0.0.0

  First version


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

  {log}   = require'util'
  sampler = require 'sampler'
  Twitter = require 'ntwitter'

  # connect to Twitter using your own credential
  twit = new Twitter
    consumer_key: 'Twitter'
    consumer_secret: 'API'
    access_token_key: 'keys'
    access_token_secret: 'go here'

  # let's open a stream on random tweets
  twit.stream 'statuses/sample', (stream) ->

    # that's all you have to do!
    recorder = new sampler.StreamRecorder(stream)

    terminate = ->
      stream.pause()

      # let's play some music!
      # by default a sampler will simply playback the event
      # (it's in autorun + speed 1x by default)
      player = new sampler.SimplePlayer(recorder.record)

    setTimeout terminate, 10000


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


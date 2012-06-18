# node-sampler

 A library which record things and play them back

## Overview

 You can record events from virtually any source (streams, event emitters, files, lines, code, message queues.. maybe even audio!)
 store them in a database (for the moment, memory only, but more backends are coming)
 and play these events slower (or faster).

 This can be very useful if you deal with machine learning algorithms that need to be trained
 on long time-series (eg. Twitter streams). You can also use it to simulate stuff like HTTP request etc..

### Current status

  This library is still in development so expect heavy refactoring and sparse documentation until I have more time to settle everything.
  
  However it is somehow functional, for basic use or/and fun. check the twitter example :)

### Features

  * control the playback speed (slower or faster)
  * accurate scheduler (latency if automatically corrected)
  * simple API - with unit tests!
  * basic Twitter example

### TODO / Wishlist
  
  * full support the Stream API (still incomplete/non functional)
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

### For developers

  To install node-sampler in a development setup:

    $ git clone http://github.com/daizoru/node-sampler.git

  Run the tests (you need mocha. it seems I cannot put it in dev dependencies, or it does a cyclic loop):

    $ npm run-script test 

  To build the coffee-script:

    $ npm run-script build


## Documentation

  Sampler has two differents APIs: one for classic, quick & dirty code (Simple API),
  the second for cleaner, async streamlined code (Stream API)

### Simple API

Record formats

``` coffeescript

{Record} = require 'sampler'

# data will be stored in memory
#record = new Record()

# stored as YAML file 
# (not very good: issues with encoding of international tweets, for instance)
record = new Record "file://examples/test.yml"


# stored as JSON file 
# not bad, it's compact (1 line) however it might not be very good for large files
record = new Record "file://examples/test.json"

# stored as SAMPLE file 
# compressed json, using Snappy
record = new Record "file://examples/test.smp"

```

Recording

``` coffeescript

{Record, SimpleRecorder} = require 'sampler'

# create a brand new record
# if there is no argument, data is stored in memory
#record = new Record()

# file:// protocol need a path with a valid extension to guess the format (yaml,yml,json)
record = new Record("file://examples/test.yaml")

# now, you can start playing with your record. 
# let's record things in the record! for this, you need a Recorder
recorder = new SimpleRecorder(record)

# then just write things inside
recorder.write "hello"
recorder.write foo: "hello", bar: "world"
recorder.write new Buffer()

# not yet implemented, but soon you will be able to add an event at a specific time
# recorder.writeAt moment(1982,1,1), "cold wave"

# also, don't forget to close the recorder when you don't use it anymore
# the reason is that a recorder start some background processes
# (eg. async synchronization of database) that need to be stopped manually
# if there is not more data to record. 
recorder.stop()


```

Playback

``` coffeescript

{Record, SimplePlayer} = require 'sampler'

# load an existing record - for the moment.. nothing is supported :) only in-memory
# but in the future, you will be able to load MongoDB, SQL, Redis records etc..
record = new Record("redis://foobar")

# create a basic player
player = new SimplePlayer(record)

```

### Stream API

Recording

``` coffeescript

{Record, StreamRecorder} = require 'sampler'

record = new Record "file://examples/twitter.json"

recorder = new StreamRecorder record

myInputStream.pipe(recorder)

# that's all folks!
# you don't need to close explicitely the StreamRecorder (unlike SimpleRecorder)
# since it can detect automatically 'close' events from input stream
```


Playing

``` coffeescript

{Record, StreamPlayer} = require 'sampler'

record = new Record "file://examples/twitter.json"

player = new StreamPlayer record

# by default there is no timestamps, however you can enable them using:
player = new StreamPlayer record,
  withTimestamp: yes
# this will emit messages in the form {timestamp, data}


# to listen to events, just do:
player.on 'data', (data) ->
  # do something with the data

player.on 'end', ->
  # finished!

```

Piping

``` coffeescript

# to be continued

```

## Examples

### Playing with Twitter Stream

  NOTE 1: you need to install ntwitter manually before running the example:

   $ npm install -g ntwitter

  I didn't include it as a dependency to keep dependencies light.

  NOTE 2: you need to have some some environment variables containing your Twitter tokens

``` coffeescript

# standard node library
{log,inspect} = require 'util'

# third-parties libraries
Twitter =       require 'ntwitter'
moment =        require 'moment'

# sampler modules
sampler =       require '../lib/sampler'

# shortcuts
delay = (t, f) -> setTimeout f, t

# PARAMETERS
duration = 10
timeline = new sampler.Record "file://twitter.json"
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
    # there is a bug in ntwitter. sometimes tweets come from here!
    if err.text?
      timeline.write moment(err.created_at), err.text

  stream.on 'data', (data) -> 
    timeline.write moment(data.created_at), data.text
  delay duration*1000, ->
    recorder.close()
    log "playing tweets back"
    new sampler.SimplePlayer timeline,
      speed: 2.0
      withTimestamp: yes
      onData: (event) ->
        log "#{event.timestamp}: #{inspect event.data}"
      onEnd: ->
        process.exit()
  log "listening for #{duration} seconds"

```


## Changelog

### 0.0.5

 * now we can load a json file! and it's tested!
 * more bugfixes
 * more tests
 * addd a recorder.close() function

### 0.0.4

 * Fixed broken YAML dependency

### 0.0.3
 
 * receiving timestamps during playback is now optional (disabled by default)
 * various bugfixes
 * tests are passing
 * basic support for file storage in YAML, JSON and JSON + Snappy
 * experimental support of Node's Stream API

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


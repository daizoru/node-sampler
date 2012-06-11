# node-sampler

 A library which record things and play them back

## Overview

 Record byte streams/events (eg. twitter, music, IRC, Apache logs..) and play them back (eg. to test or debug an app, reproduce errors, simulate events)

 One the of main features is that you can control the rate speed, 
 very useful to train machine learning algorithms on historic data (eg. Twitter streams)

### Current status

  This library is still in development so expect heavy refactoring and sparse documentation until I have more time to settle everything.

### TODO / Wishlist

  * real support of stream/buffer API. for the moment it's only a basic system based on event emitter
  * save/export samples (to databases, files..)
  * load/import samples (from APIs, databases, CSVs..)
  * insertion of event at arbitrary timesteps (eg. when working with incomplete time-series)
  * reverse playback!
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

### Example

``` coffeescript

Sampler = require 'sampler'

# for the moment, this create a default, in-memory sampler
sp = new Sampler()

# listen to events
sp.on 'event', (event) -> log "#{event.timestamp}: #{event.data}"
sp.on 'end', -> log "finished"

# coffee-style timeouts
delay = (t,f) -> setTimeout f, t

# sample some dummy events
log "sampling events.."
delay 100, -> sp.rec companyhelpdesk: "hi how can I help you"
delay 500, -> sp.rec facebook: "wow! this was a big earthquake"
delay 1000, -> sp.rec twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"
delay 1500, -> sp.rec twitter: "ZOMBIE APOCALYPSE!!1!!"

delay 2000, -> 
  log "playing events back.."
  sp.play()

delay 5000, -> 
  log "playing events back. and faster."
  sp.play 2.0 # twice faster!

```

  which should output something like:

```

10 Jun 14:57:49 - sampling events..
10 Jun 14:57:51 - playing events back..
10 Jun 14:57:51 - 1339333069383: { companyhelpdesk: 'hi how can I help you' }
10 Jun 14:57:51 - 1339333069783: { facebook: 'wow! this was a big earthquake' }
10 Jun 14:57:52 - 1339333070284: { twitter: 'just saw my dead neighbor walking in my street. It\'s weird. wait I\'m gonna check it out' }
10 Jun 14:57:52 - 1339333070784: { twitter: 'ZOMBIE APOCALYPSE!!1!!' }
10 Jun 14:57:52 - finished
10 Jun 14:57:54 - playing events back. and faster.
10 Jun 14:57:54 - 1339333069383: { companyhelpdesk: 'hi how can I help you' }
10 Jun 14:57:54 - 1339333069783: { facebook: 'wow! this was a big earthquake' }
10 Jun 14:57:54 - 1339333070284: { twitter: 'just saw my dead neighbor walking in my street. It\'s weird. wait I\'m gonna check it out' }
10 Jun 14:57:54 - 1339333070784: { twitter: 'ZOMBIE APOCALYPSE!!1!!' }
10 Jun 14:57:54 - finished

```

  To be continued


## Changelog

### 0.0.1

 I Added a callback when the playback reach the end:
 
``` javascript

  sampler.on("end", function() {
    console.log("playback terminated")
  })
  
```

### 0.0.0

  First version


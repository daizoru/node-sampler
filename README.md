# node-recorder

 A library which record things and play them back

## Overview

 Record byte streams/events (eg. twitter, music, IRC, Apache logs..) and play them back (eg. to test or debug an app, reproduce errors, simulate events)

 One the of main features is that you can control the rate speed, 
 very useful to train machine learning algorithms on historic data (eg. Twitter streams)

### Current status

  This library is still in development so expect heavy refactoring and sparse documentation until I have more time to settle everything.

### TODO / Wishlist

  * insertion of event at arbitrary timesteps (eg. when working with incomplete time-series)
  * reverse playback!

### License

  BSD

## Installation

### For users

#### Install it as a dependency for your project

    $ npm install recorder

#### Install it globally in your system

    $ npm install recorder -g

#### Run the tests

    $ npm run-script test

### For developers

  To install node-recorder in a development setup:

    $ git clone http://github.com/daizoru/node-recorder.git
    $ cd node-recorder
    $ npm link
    $ # optional:
    $ # npm run-script test 

  To build the coffee-script:

    $ npm run-script build


## Documentation

### Example

``` coffeescript
# myapp.coffee
Recorder = require 'recorder'

record = new Recorder()
record.on 'event', (event) -> log "#{event.timestamp}: #{event.data}"

# coffee-style timeouts
delay = (t,f) -> setTimeout f, t

# record some dummy events
log "recording events.."
delay 100, -> record.rec companyhelpdesk: "hi how can I help you"
delay 500, -> record.rec facebook: "wow! this was a big earthquake"
delay 1000, -> record.rec twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"
delay 1500, -> record.rec twitter: "ZOMBIE APOCALYPSE!!1!!"

delay 2000, -> 
  log "playing events back.."
  record.play()

delay 5000, -> 
  log "playing events back. and faster."
  record.play 5.0 # 2.0x

```

  which should output something like:

```

10 Jun 14:57:49 - recording events..
10 Jun 14:57:51 - playing events back..
10 Jun 14:57:51 - 1339333069383: { companyhelpdesk: 'hi how can I help you' }
10 Jun 14:57:51 - 1339333069783: { facebook: 'wow! this was a big earthquake' }
10 Jun 14:57:52 - 1339333070284: { twitter: 'just saw my dead neighbor walking in my street. It\'s weird. wait I\'m gonna check it out' }
10 Jun 14:57:52 - 1339333070784: { twitter: 'ZOMBIE APOCALYPSE!!1!!' }
10 Jun 14:57:54 - playing events back. and faster.
10 Jun 14:57:54 - 1339333069383: { companyhelpdesk: 'hi how can I help you' }
10 Jun 14:57:54 - 1339333069783: { facebook: 'wow! this was a big earthquake' }
10 Jun 14:57:54 - 1339333070284: { twitter: 'just saw my dead neighbor walking in my street. It\'s weird. wait I\'m gonna check it out' }
10 Jun 14:57:54 - 1339333070784: { twitter: 'ZOMBIE APOCALYPSE!!1!!' }

```

  You can see it here but the second batch is two times faster


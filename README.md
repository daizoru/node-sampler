# node-recorder

 A library which record things and play them back

## Overview

 Record byte streams/events (eg. twitter, music, IRC, Apache logs..) and play them back (eg. to test or debug an app, reproduce errors, simulate events)

 One the of main features is that you can control the rate speed, 
 very useful to train machine learning algorithms on historic data (eg. Twitter streams)

### Current status

  This library is still in development so expect heavy refactoring and sparse documentation until I have more time to settle everything.

### License

  BSD

## Installation

### For users

#### Install it as a dependency for your project

    $ npm install http://github.com/daizoru/node-recorder.git

#### Install it globally in your system

    $ npm install http://github.com/daizoru/node-recorder.git -g

#### Run the tests

    $ npm run-script test

### For developers

  To install node-recorder in a development setup:

    $ git clone http://github.com/daizoru/node-recorder.git
    $ cd node-recorder
    $ npm link
    $ # optional:
    $ # npm run-script test 

## Documentation

### How it works

  Add some documentation here

  alert (from node.js docs):

  It is important to note that your callback will probably not be called with the exact temporal sequence - Node.js makes no guarantees about the exact timing of when the callback will fire, nor of the ordering things will fire in. The callback will be called as close as possible to the time specified.
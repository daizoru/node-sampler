#!/usr/bin/env coffee

# standard node library
{log,inspect}   = require 'util'

# sampler modules
sampler = require '../lib/sampler'
delay = (t, f) -> setTimeout f, t

new sampler.SimplePlayer "file://twitter.smp",
  speed: 2.0
  onData: (data) -> log "TWEET: #{data}"

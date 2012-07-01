#!/usr/bin/env coffee

# standard node library
{log,inspect}   = require 'util'

# third-parties libraries
Twitter = require 'ntwitter'
moment = require 'moment'

# sampler modules
sampler = require '../lib/sampler'
delay = (t, f) -> setTimeout f, t

# PARAMETERS
duration = 8
timeline = new sampler.Record "file://twitter.smp"
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
    if err.code?
      log "this is a serious error. exiting"
      process.exit()
      
    if err.text?
      recorder.writeAt moment(err.created_at), err.text
  stream.on 'data', (data) -> 
    recorder.writeAt moment(data.created_at), data.text
  delay duration*1000, ->
    log "recording terminated, will soon exit.."
    stream.destroy() # clean exit?
    delay 5000, -> process.exit()
  log "listening for #{duration} seconds"
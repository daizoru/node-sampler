# standard node library
{log}   = require 'util'

# third-parties libraries
Twitter = require 'ntwitter'

# sampler modules
sampler = require '../lib/sampler'

delay = (t, f) -> setTimeout f, t

# connect to Twitter using your own credential
twit = new Twitter
  consumer_key: process.env.TWITTER_CONSUMER_KEY
  consumer_secret: process.env.TWITTER_CONSUMER_SECRET
  access_token_key: process.env.TWITTER_TOKEN_KEY
  access_token_secret: process.env.TWITTER_TOKEN_SECRET

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

  delay 15000, terminate
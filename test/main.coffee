Sampler = require '../lib/sampler'
{log,error,inspect} = require 'util'
delay = (t,f) -> setTimeout f, t

# these are not real tests, it's more like a demo
# more complete tests should check for returned values!!!

# our tests
describe 'Sampler', ->
  describe '#Sampler()', ->
    it 'should record', (done) ->
      sample = new Sampler()
      sample.on 'event', (event) -> log "#{event.timestamp}: #{inspect event.data}"

      # sample some dummy events
      log "sampling events.."
      delay 100, -> sample.rec companyhelpdesk: "hi how can I help you"
      delay 500, -> sample.rec facebook: "wow! this was a big earthquake"
      delay 1000, -> sample.rec twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"
      delay 1500, -> sample.rec twitter: "ZOMBIE APOCALYPSE!!1!!"
      delay 1600, -> done()

    it 'should playback at normal speed', (done) ->
      sample = new Sampler()
      sample.on 'event', (event) -> log "#{event.timestamp}: #{inspect event.data}"

      # sample some dummy events
      log "sampling events.."
      delay 100, -> sample.rec companyhelpdesk: "hi how can I help you"
      delay 500, -> sample.rec facebook: "wow! this was a big earthquake"
      delay 1000, -> sample.rec twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"
      delay 1500, -> sample.rec twitter: "ZOMBIE APOCALYPSE!!1!!"

      delay 1600, -> 
        log "playing events back.."
        sample.play()
        done()

        #if (err) throw err

    it 'should playback faster', (done) ->
      sample = new Sampler()
      sample.on 'event', (event) -> log "#{event.timestamp}: #{inspect event.data}"

      # sample some dummy events
      log "sampling events.."
      delay 100, -> sample.rec companyhelpdesk: "hi how can I help you"
      delay 500, -> sample.rec facebook: "wow! this was a big earthquake"
      delay 1000, -> sample.rec twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"
      delay 1500, -> sample.rec twitter: "ZOMBIE APOCALYPSE!!1!!"

      delay 1600, -> 
        log "playing events faster.."
        sample.play 4.0
        done()

        #if (err) throw err

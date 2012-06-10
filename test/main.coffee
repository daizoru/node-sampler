Recorder = require '../lib/recorder'
{log,error,inspect} = require 'util'
delay = (t,f) -> setTimeout f, t

# these are not real tests, it's more like a demo
# more complete tests should check for returned values!!!

# our tests
describe 'Recorder', ->
  describe '#new Recorder()', ->
    it 'should work', (done) ->
    
      record = new Recorder()
      record.on 'event', (event) -> log "#{event.timestamp}: #{inspect event.data}"

      # record some dummy events
      log "recording events.."
      delay 100, -> record.rec companyhelpdesk: "hi how can I help you"
      delay 500, -> record.rec facebook: "wow! this was a big earthquake"
      delay 1000, -> record.rec twitter: "just saw my dead neighbor walking in my street. It's weird. wait I'm gonna check it out"
      delay 1500, -> record.rec twitter: "ZOMBIE APOCALYPSE!!1!!"

      delay 1600, -> 
        log "playing events back.."
        record.play()

        delay 100, -> 
          log "playing events back. and faster."
          record.play 5.0 # 2.0x
          done()

          #if (err) throw err

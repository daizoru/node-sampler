recorder = require '../lib/recorder'

# our tests
describe 'Recorder', ->
  describe '#new Recorder()', ->
    it 'should work', (done) ->
      recorder = new Recorder()
      recorder.insert foo: 'bar'
      #if (err) throw err
      done()
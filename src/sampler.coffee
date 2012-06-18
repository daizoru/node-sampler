stream = require './api/stream'
simple = require './api/simple'
Record = require './record'

exports.Record         = Record
exports.SimpleRecorder = simple.Recorder
exports.SimplePlayer   = simple.Player
exports.StreamRecorder = stream.Recorder
exports.StreamPlayer   = stream.Player

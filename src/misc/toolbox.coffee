
delay = exports.delay = (t,f) -> setTimeout f, t

contains = exports.contains = (item, text) -> (text.indexOf(item) isnt -1)

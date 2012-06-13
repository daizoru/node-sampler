# author: hector@hectorcorrea.com
# https://github.com/hectorcorrea/binary-tree-coffee

class BinaryNode

  constructor: (@event) -> 
    @left = null
    @right = null

class module.exports

  constructor: (rootEvent) ->
    @root = new BinaryNode rootEvent
    @count = 1

  push: (event) ->
    newNode = new BinaryNode event
    node = @root
    loop
      if newNode.event.timestamp >= node.event.timestamp
        if node.right is null
          node.right = newNode
          break
        else
          node = node.right
      else
        if node.left is null
          node.left = newNode
          break
        else
          node = node.left

    @count++ 

  walk: (callback) ->
    @walkFromNode callback, @root

  walkFromNode: (callback, node) ->
    @walkFromNode(callback, node.left) unless node.left is null
    callback node
    @walkFromNode(callback, node.right) unless node.right is null

  toString: ->
    timestamps = []
    @walk (node) -> timestamps.push node.event.timestamp
    timestamps.join ', '

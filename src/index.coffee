{DepGraph} = require 'dependency-graph'

class ExpressStackBuilder

  constructor: ->
    @_counter = 0
    @_graph = new DepGraph
    @_graph.addNode ':before'
    @_graph.addNode ':app'
    @_graph.addNode ':after'
    @_graph.addDependency ':app', ':before'
    @_graph.addDependency ':after', ':app'
    @_calls = {}

  beforeAll: ->
    use: (args...) =>
      key = @_use args
      @_graph.addDependency ':before', key

  afterAll: ->
    use: (args...) =>
      key = @_use args
      @_graph.addDependency key, ':after'

  _use: (args) ->
    key = "c:#{++@_counter}"
    @_calls[key] = ['use', args...]
    @_graph.addNode key
    return key

  use: (args...) ->
    key = @_use args
    @_graph.addDependency ':app', key

  toArray: ->
    calls = []
    for key in @_graph.overallOrder()
      continue unless (call = @_calls[key])?
      calls.push call
    return calls

module.exports = ExpressStackBuilder

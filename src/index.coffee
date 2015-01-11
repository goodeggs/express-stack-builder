{DepGraph} = require 'dependency-graph'

expressApiBuilder = (callStack) ->
  api = {}
  for method in ['use', 'all', 'get', 'put', 'post', 'delete', 'head', 'options']
    api[method] = do (method) ->
      (args...) ->
        callStack.push [method, args...]
  api

class ExpressStackBuilder

  constructor: (@_graph, @_ns) ->
    @_graph ?= new DepGraph
    @_ns ?= {}
    @_callStacks =
      beforeAll: []
      before: []
      app: []
      after: []
      afterAll: []
    for k, v of @_callStacks when k isnt 'app'
      @[k] = expressApiBuilder(v)
    @[name] = fn for name, fn of expressApiBuilder(@_callStacks.app)

  namespace: (ns, dependencies=[]) ->
    @_graph.addNode ns
    for dependency in dependencies
      @_graph.addNode dependency # ensure node exists
      @_graph.addDependency ns, dependency
    return @_ns[ns] = new ExpressStackBuilder @_graph, @_ns

  merge: (callObj) ->
    newObj = {}
    for k, v of callObj
      newObj[k] = callObj[k].concat(@_callStacks[k])
    return newObj

  configure: (express, appFn) ->
    calls = @_callStacks
    for ns in @_graph.overallOrder()
      calls = @_ns[ns].merge calls

    for stack in ['beforeAll', 'before', 'app']
      for [fn, args...] in calls[stack]
        express[fn](args...)

    appFn?()

    for stack in ['after', 'afterAll']
      for [fn, args...] in calls[stack]
        express[fn](args...)

module.exports = ExpressStackBuilder

ExpressStackBuilder = require '..'
{expect} = require 'chai'

describe 'express-stack-builder', ->
  {stack} = {}

  beforeEach ->
    stack = new ExpressStackBuilder

  describe 'with no configuration', ->

    it 'generates an empty stack', ->
      expect(stack.toArray()).to.have.length 0

  describe 'with some entries', ->
    {fn1, fn2} = {}

    beforeEach ->
      fn1 = ->
      fn2 = ->
      stack.use fn1
      stack.use fn2

    describe '::beforeAll', ->
      {fn} = {}

      beforeEach ->
        fn = ->
        stack.beforeAll().use fn

      it 'inserts fn at the top of the stack', ->
        expect(stack.toArray()).to.eql [
          ['use', fn]
          ['use', fn1]
          ['use', fn2]
        ]

    describe '::afterAll', ->
      {fn3, fn4} = {}

      beforeEach ->
        fn3 = ->
        fn4 = ->
        stack.afterAll().use fn3
        stack.use fn4

      it 'inserts fn3 at the bottom of the stack', ->
        expect(stack.toArray()).to.eql [
          ['use', fn1]
          ['use', fn2]
          ['use', fn4]
          ['use', fn3]
        ]


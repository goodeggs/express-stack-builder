ExpressStackBuilder = require '..'
{expect} = chai = require 'chai'
sinon = require 'sinon'
chai.use require('sinon-chai')

describe 'express-stack-builder', ->
  {stack, express} = {}

  beforeEach ->
    stack = new ExpressStackBuilder
    express = use: sinon.spy()

  describe 'with no configuration', ->
    beforeEach ->
      stack.configure express

    it 'does not call express', ->
      expect(express.use).not.to.have.been.called

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
        stack.beforeAll.use fn
        stack.configure express

      it 'inserts fn at the top of the stack', ->
        expect(express.use.args).to.eql [
          [fn]
          [fn1]
          [fn2]
        ]

    describe '::afterAll', ->
      {fn3, fn4} = {}

      beforeEach ->
        fn3 = ->
        fn4 = ->
        stack.afterAll.use fn3
        stack.use fn4
        stack.configure express

      it 'inserts fn3 at the bottom of the stack', ->
        expect(express.use.args).to.eql [
          [fn1]
          [fn2]
          [fn4]
          [fn3]
        ]

    describe '::namespace', ->
      {fn3} = {}

      beforeEach ->
        fn3 = ->
        stack.namespace('foo').use fn3
        stack.configure express

      it 'inserts fn3', ->
        expect(express.use.args).to.eql [
          [fn1]
          [fn2]
          [fn3]
        ]

    describe 'dependencies', ->
      {fn3, fn4} = {}

      beforeEach ->
        fn3 = ->
        fn4 = ->
        stack.namespace('goodeggs-logger', ['goodeggs-stats']).use fn3
        stack.namespace('goodeggs-stats').use fn4
        stack.configure express

      it 'inserts fn4 before fn3', ->
        expect(express.use.args).to.eql [
          [fn1]
          [fn2]
          [fn4]
          [fn3]
        ]


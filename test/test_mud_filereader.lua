#!/usr/bin/lua

local mu = require("mudv2")
local lu = require("luaunit")

local json = require("cjson")

TestMud = {} --class
    function TestMud:setup()
      self.a = mu.mud.create()
      self.b = mu.mud.create()
    end

    function TestMud:testDraftExample()
      self.a = mu.mud.create()
      self.a:parseFile("../examples/example_from_draft.json")
      --self.a:parseFile("/tmp/mini-example.json")
      self.a:print()
    end
-- class testMud


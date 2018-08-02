#!/usr/bin/lua

local mu = require("mudv2")
local lu = require("luaunit")

local json = require("cjson")

TestMud = {} --class
  function TestMud:setup()
    self.a = mu.mud.create()
    self.a:parseFile("../examples/example_from_draft.json")
  end

  function TestMud:testMakeRules()
    self.a:makeRules()
  end
-- class testMud


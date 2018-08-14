#!/usr/bin/lua

local mu = require("mudv2")
local lu = require("luaunit")
local yang = require("yang")

local json = require("cjson")

TestMudFind = {} --class
  function TestMudFind:setup()
    self.a = mu.mud.create()
    self.a:parseFile("../examples/example_from_draft.json")
  end

  function TestMudFind:testFind()
    yang.findNodeWithProperty(self.a.mud_container, 'ietf-mud:mud', 'mud-version', 1)
  end

  function TestMudFind:testFind2()
    --self.a:print()
  end

  function TestMudFind:testFind3()
  end
-- class testMud


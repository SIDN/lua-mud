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

  function TestMudFind:testFindBadNode()
    --self.a:print()
    intNode = yang.basic_types.uint8:create("int")
    lu.assertError(yang.findNodeWithProperty, intNode, 'int', 'bar', 2)
    lu.assertError(yang.findNodeWithProperty, self.a.mud_container, 'no_such_element', 'bar', 2)
  end

  function TestMudFind:testFind3()
  end
-- class testMud


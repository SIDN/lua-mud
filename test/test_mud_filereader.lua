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

  function TestMud:testGetNode()
    self.a = mu.mud.create()
    self.a:parseFile("../examples/example_from_draft.json")

    -- note: we don't support absolute paths yet
    lu.assertEquals(self.a.mud:getNode("mud-version"):getValue(), 1)
    lu.assertEquals(self.a.mud:getNode("mud-version"):toData(), 1)
    lu.assertEquals(self.a.mud:getNode("from-device-policy/access-lists/access-list[1]/name"):toData(), "mud-76100-v6fr")

    lu.assertError(self.a.mud.getNode, self.a.mud, "from-device-policy/acceBADNAMEss-lists/access-list[1]/name")
    lu.assertError(self.a.mud.getNode, self.a.mud, "from-device-policy/access-lists/access-list[100]/name")
    lu.assertError(self.a.mud.getNode, self.a.mud, "from-device-policy/access-lists/access-list[-1]/name")
    lu.assertError(self.a.mud.getNode, self.a.mud, "from-device-policy/access-lists/access-list/name")
  end
-- class testMud


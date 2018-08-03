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
    local rules = self.a:makeRules()
    local expect = {
      "nft add rule inet filter output ip6 daddr test.example.com tcp dport 443 accept",
      "nft add rule inet filter output ip6 saddr test.example.com tcp sport 443 accept"
    }
    lu.assertEquals(rules, expect)
  end
-- class testMud


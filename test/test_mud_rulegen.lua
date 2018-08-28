#!/usr/bin/lua

local mu = require("mudv2")
local lu = require("luaunit")

local json = require("cjson")

TestMudRulegen = {} --class
  function TestMudRulegen:setup()
    self.a = mu.mud.create()
    self.a:parseFile("../examples/example_from_draft.json")
  end

  function TestMudRulegen:testMakeRules()
    local rules = self.a:makeRules()
    -- hmz, order is undefined with dicts...
    local expect = {
      "nft add rule inet filter output ip6 tcp dport 443 daddr example.com accept",
      "nft add rule inet filter output ip6 tcp sport 443 saddr example.com accept"
    }

    lu.assertEquals(rules, expect)
  end

  function TestMudRulegen:testMudMakerExample()
    local b = mu.mud.create()
    b:parseFile("../examples/example_from_mudmaker.json")
    for i,r in pairs(b:makeRules()) do
      print(r)
    end
  end

  function TestMudRulegen:testIPTables()
    local b = mu.mud.create()
    local status = b:parseFile("../examples/example_from_draft.json")
    for i,r in pairs(b:makeRulesIPTables()) do
      --print("IPTABLES: " .. r)
    end
  end
-- class testMud


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
      "nft add rule inet filter output ip6 daddr test.example.com tcp dport 443 accept",
      "nft add rule inet filter output ip6 saddr test.example.com tcp sport 443 accept"
    }
    local expect = {
      "nft add rule inet filter output ip6 tcp dport 443 daddr test.example.com accept",
      "nft add rule inet filter output ip6 tcp sport 443 saddr test.example.com accept"
    }

    lu.assertEquals(rules, expect)
  end

  function TestMudRulegen:testMudMakerExample()
    local b = mu.mud.create()
    b:parseFile("../examples/example_from_mudmaker.json")
    for i,r in pairs(b:makeRules()) do
      print(r)
    end

    --self.a:print()
  end

-- class testMud


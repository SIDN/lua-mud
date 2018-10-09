#!/usr/bin/lua

local mu = require("mud.mud")
local lu = require("luaunit")

local iptables_rb = require("mud.rulebuilders.iptables")
local nftables_rb = require("mud.rulebuilders.nftables")

local json = require("cjson")
local lua_mud_environment = require("mud.mud_environment")
 
TestMudRulegen = {} --class
  function TestMudRulegen:setup()
    self.env =  lua_mud_environment.create()
    self.env:setDeviceIPv4("192.0.2.2")
    self.env:setDeviceIPv6("2001:DB8::/32")
    self.env:setDeviceMac("aa:bb:cc:dd:ee:ff")
    self.env:setNetwork("192.0.2.0/24")

    self.a = mu.mud.create()
    self.a:parseFile("../examples/example_from_draft.json")
  end

  function TestMudRulegen:testMakeRules()
    builder = nftables_rb.create_rulebuilder()
    local rules = builder:build_rules(self.a, self.env)
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
    builder = nftables_rb.create_rulebuilder()
    local rules = builder:build_rules(self.a, self.env)
    for i,r in pairs(rules) do
      print(r)
    end
  end

  function TestMudRulegen:testIPTables()
    local b = mu.mud.create()
    b:parseFile("../examples/example_cloudservice.json")

    local rb = iptables_rb.create_rulebuilder()
    local rules = rb:build_rules(b, self.env)
    --local rules = rb:build_rules(self.a)
    for i,r in pairs(rules) do
      print("[XX] RULE: " .. r)
    end
  end
-- class testMud


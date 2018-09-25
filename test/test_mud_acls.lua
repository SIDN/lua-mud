#!/usr/bin/lua

local mu = require("mud.mud")
local lu = require("luaunit")

local iptables_rb = require("mud.rulebuilders.iptables")
local nftables_rb = require("mud.rulebuilders.nftables")

local json = require("cjson")

local function readFile(filename)
  local f = assert(io.open(filename, "rb"))
  local content = f:read("*all")
  f:close()
  return content
end

local function writeFile(filename, data)
  local f = assert(io.open(filename, "w"))
  f:write(json.encode(data))
  f:close()
end

TestMudACLs = {} --class
  function TestMudACLs:setup()
    self.a = mu.mud.create()
  end

-- class testMud


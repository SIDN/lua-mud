#!/usr/bin/lua

local mu = require("mud")
local lu = require("luaunit")

local iptables_rb = require("rulebuilders/iptables")
local nftables_rb = require("rulebuilders/nftables")

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

  function TestMudACLs:testParseMudFiles()
    local files =
      {
        --"../examples/example_from_draft.json",
        --"../examples/example_from_mudmaker.json",
        --"../examples/example_cloudservice.json",
        --"../examples/custom_example.json",
        "../examples/test1.json",
        --"../examples/test2.json"
      }
    for i,filename in pairs(files) do
        local b = mu.mud.create()
        local input_data = json.decode(readFile(filename))

        b:parseFile(filename)
        --print("[XX] full data:")
        --print(json.encode(b.mud_container:toData()))
        --print("[XX] end of full data")

        writeFile("/tmp/a.json", input_data)
        writeFile("/tmp/b.json", b.mud_container:toData())

        lu.assertEquals(b.mud_container:toData(), input_data)
    end

    --local rb = iptables_rb.create_rulebuilder()
    --local rules = rb:build_rules(b)
    --for i,r in pairs(rules) do
    --  print("[XX] RULE: " .. r)
    --end
  end
-- class testMud


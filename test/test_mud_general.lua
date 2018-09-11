#!/usr/bin/lua

local mu = require("mud")
local lu = require("luaunit")

local json = require("cjson")

TestMudGeneral = {} --class
  function TestMudGeneral:setup()
    self.a = mu.mud.create()
  end

  function TestMudGeneral:testNoMudSection()
    lu.assertError(self.a.parseJSON, self, "{}")
  end

  function TestMudGeneral:testNoFile()
    lu.assertError(self.a.parseFile, self, nil)
    lu.assertError(self.a.parseFile, self, "/does/not/exist")
  end
-- class testMud


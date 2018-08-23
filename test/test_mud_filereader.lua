#!/usr/bin/lua

local mu = require("mudv2")
local yang = require("yang")
local lu = require("luaunit")

local json = require("cjson")

TestMudFileReader = {} --class
  function TestMudFileReader:setup()
    self.a = mu.mud.create()
    self.b = mu.mud.create()
  end

  function TestMudFileReader:testDraftExample()
    self.a:parseFile("../examples/example_from_draft.json")
  end

  function TestMudFileReader:testMudMakerExample()
    self.a:parseFile("../examples/example_from_mudmaker.json")
    --self.a:print()
  end

  function TestMudFileReader:testMudMakerExample2()
    -- disabled for now, we don't support the match type ietf-mud:mud yet
    --self.a:parseFile("../examples/example_from_mudmaker2.json")
    --self.a:print()
  end

  function TestMudFileReader:testGetNode()
    self.a = mu.mud.create()
    self.a:parseFile("../examples/example_from_draft.json")

    -- note: we don't support absolute paths yet
    lu.assertEquals(self.a.mud_container:getNode("ietf-mud:mud/mud-version"):getValue(), 1)
    lu.assertEquals(self.a.mud_container:getNode("ietf-mud:mud/mud-version"):toData(), 1)
    lu.assertEquals(self.a.mud_container:getNode("ietf-mud:mud/from-device-policy/access-lists/access-list[1]/name"):toData(), "mud-76100-v6fr")

    lu.assertError(self.a.mud_container.getNode, self.a.mud, "from-device-policy/acceBADNAMEss-lists/access-list[1]/name")
    lu.assertError(self.a.mud_container.getNode, self.a.mud, "from-device-policy/access-lists/access-list[100]/name")
    lu.assertError(self.a.mud_container.getNode, self.a.mud, "from-device-policy/access-lists/access-list[-1]/name")
    lu.assertError(self.a.mud_container.getNode, self.a.mud, "from-device-policy/access-lists/access-list/name")
  end

  function TestMudFileReader:testGetPath()
    self.a:parseFile("../examples/example_from_draft.json")
    print(json.encode(self.a.mud_container:toData()))
  end

  function TestMudFileReader:testGetPath2()
    self.a:parseFile("../examples/example_from_draft.json")
    lu.assertEquals(self.a.mud_container:getRootNode():getName(), "mud-container")
    lu.assertEquals(self.a.mud_container.yang_nodes['ietf-mud:mud']:getRootNode():getName(), "mud-container")
    lu.assertEquals(self.a.mud_container.yang_nodes['ietf-mud:mud'].yang_nodes['to-device-policy']:getRootNode():getName(), "mud-container")
    local n = self.a.mud_container.yang_nodes['ietf-access-control-list:acls'].yang_nodes['acl'].value[2].yang_nodes["aces"].yang_nodes["ace"].value[1].yang_nodes['matches'].yang_nodes['l5'].cases['ipv6']
    --local n = self.a.mud_container.yang_nodes['ietf-access-control-list:acls'].yang_nodes['acl'].value[2].yang_nodes["aces"].yang_nodes["ace"].value[1].yang_nodes['matches']
    --error(n:getName() .. " (" .. n:getType() .. "): " .. json.encode(n:toData()))
    lu.assertEquals(n:getPath(), "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/matches/ipv6")
  end

  function TestMudFileReader:testGetPath3()
    self.a:parseFile("../examples/example_from_draft.json")
    local paths = {}
    for i,n in pairs(self.a.mud_container:getAll()) do
      print("[XX] calling getpath[] " .. i)
      table.insert(paths, n:getPath())
    end
    local expected = {
    }

    lu.assertEquals(paths, expected)
  end
-- class testMudFileReader


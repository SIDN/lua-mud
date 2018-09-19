#!/usr/bin/lua

local mu = require("mud")
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
  end

  function TestMudFileReader:testMudMakerExample2()
    -- disabled for now, we don't support the match type ietf-mud:mud yet
    --self.a:parseFile("../examples/example_from_mudmaker2.json")
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
    lu.assertEquals(self.a.mud_container:getRootNode():getName(), "mud-container")
    lu.assertEquals(self.a.mud_container.yang_nodes['ietf-mud:mud']:getRootNode():getName(), "mud-container")
    lu.assertEquals(self.a.mud_container.yang_nodes['ietf-mud:mud'].yang_nodes['to-device-policy']:getRootNode():getName(), "mud-container")
    --local n = self.a.mud_container.yang_nodes['ietf-access-control-list:acls'].yang_nodes['acl'].value[2].yang_nodes["aces"].yang_nodes["ace"].value[1].yang_nodes['matches'].yang_nodes['ipv6'].cases['ipv6']
    local n = self.a.mud_container.yang_nodes['ietf-access-control-list:acls'].yang_nodes['acl'].value[2].yang_nodes["aces"].yang_nodes["ace"].value[1].yang_nodes['matches'].yang_nodes['ipv6']
    lu.assertEquals(n:getPath(), "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/matches/ipv6")
  end

  function TestMudFileReader:testGetPath3()
    self.a:parseFile("../examples/example_from_draft.json")
    local paths = {}
    for i,n in pairs(self.a.mud_container:getAll()) do
      table.insert(paths, n:getPath())
    end
    local expected = {
      "mud-container",
      "mud-container/ietf-mud:mud",
      "mud-container/ietf-mud:mud/to-device-policy",
      "mud-container/ietf-mud:mud/to-device-policy/access-lists",
      "mud-container/ietf-mud:mud/to-device-policy/access-lists/access-list",
      "mud-container/ietf-mud:mud/to-device-policy/access-lists/access-list[1]/list_entry",
      "mud-container/ietf-mud:mud/to-device-policy/access-lists/access-list[1]/list_entry/name",
      "mud-container/ietf-mud:mud/from-device-policy",
      "mud-container/ietf-mud:mud/from-device-policy/access-lists",
      "mud-container/ietf-mud:mud/from-device-policy/access-lists/access-list",
      "mud-container/ietf-mud:mud/from-device-policy/access-lists/access-list[1]/list_entry",
      "mud-container/ietf-mud:mud/from-device-policy/access-lists/access-list[1]/list_entry/name",
      "mud-container/ietf-mud:mud/last-update",
      "mud-container/ietf-mud:mud/systeminfo",
      "mud-container/ietf-mud:mud/cache-validity",
      "mud-container/ietf-mud:mud/is-supported",
      "mud-container/ietf-mud:mud/mud-url",
      "mud-container/ietf-mud:mud/mud-version",
      "mud-container/ietf-access-control-list:acls",
      "mud-container/ietf-access-control-list:acls/acl",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry/matches",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry/matches/tcp",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry/matches/ipv6",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry/name",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry/actions",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/aces/ace[1]/list_entry/actions/forwarding",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/type",
      "mud-container/ietf-access-control-list:acls/acl[1]/list_entry/name",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/matches",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/matches/tcp",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/matches/ipv6",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/name",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/actions",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/aces/ace[1]/list_entry/actions/forwarding",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/type",
      "mud-container/ietf-access-control-list:acls/acl[2]/list_entry/name"
    }

    lu.assertEquals(paths, expected)
  end
-- class testMudFileReader


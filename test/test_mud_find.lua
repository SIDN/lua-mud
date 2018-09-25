#!/usr/bin/lua

local mu = require("mud.mud")
local lu = require("luaunit")
local yang = require("mud.yang")

local json = require("cjson")

TestMudFind = {} --class
  function TestMudFind:setup()
    self.a = mu.mud.create()
    self.a:parseFile("../examples/custom_example.json")
  end

  function TestMudFind:testFind()
    yang.findNodeWithProperty(self.a.mud_container, 'ietf-mud:mud', 'mud-version', 1)
  end

  function TestMudFind:testFindBadNode()
    intNode = yang.basic_types.uint8:create("int")
    lu.assertError(yang.findNodeWithProperty, intNode, 'int', 'bar', 2)
    lu.assertError(yang.findNodeWithProperty, self.a.mud_container, 'no_such_element', 'bar', 2)
  end

  function print_find_result(node, path)
    local nodes = yang.findNodes(node, path)
    print("Path: " .. path)
    print("Data: ")
    for i,n in pairs(nodes) do
      print("    " .. json.encode(n:toData()))
    end
    print("------------------------")
  end

  function TestMudFind:testFindNodesPaths()
    -- some full path
    local nodes = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list[1]/name")
    local expect = { "mud-76100-v6to" }
    lu.assertEquals(yang.nodeListToData(nodes), expect)

    -- relative path (which is the same since we start at the root node)
    nodes = yang.findNodes(self.a.mud_container, "ietf-mud:mud/to-device-policy/access-lists/access-list[1]/name")
    expect = { "mud-76100-v6to" }
    lu.assertEquals(yang.nodeListToData(nodes), expect)

    -- A different list element
    nodes = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list[2]/name")
    expect = { "second-acl" }
    lu.assertEquals(yang.nodeListToData(nodes), expect)

    -- All list elements. Note that the results show up as separate entries
    nodes = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list[*]/name")
    expect = { "mud-76100-v6to", "second-acl" }
    lu.assertEquals(yang.nodeListToData(nodes), expect)

    -- All list elements, but without the 'name' part. Results are separate entries including table entry names
    nodes = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list[*]")
    expect = {{ name="mud-76100-v6to" }, { name="second-acl" }}
    lu.assertEquals(yang.nodeListToData(nodes), expect)

    -- The list itself, which shows up as one entry (which is a list of tables)
    nodes = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list")
    expect = {{{ name="mud-76100-v6to" }, { name="second-acl" }}}
    lu.assertEquals(yang.nodeListToData(nodes), expect)

    -- A wildcard for a name (which happens to only have one result)
    nodes = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy/*")
    expect = {{ ["access-list"]={{name="mud-76100-v6to"}, {name="second-acl"}} }}
    lu.assertEquals(yang.nodeListToData(nodes), expect)
  end


  function TestMudFind:testFindNodesFromSubNode()
    -- take some node from down the tree, so we can check whether absolute paths work
    local sub = yang.findNodes(self.a.mud_container, "/ietf-mud:mud/to-device-policy")[1]
    lu.assertEquals(sub:getName(), 'to-device-policy')

    -- TODO: move to own test
    lu.assertEquals(self.a.mud_container:getRootNode():getName(), "mud-container")
    lu.assertEquals(self.a.mud_container.yang_nodes['ietf-mud:mud']:getRootNode():getName(), "mud-container")
    lu.assertEquals(self.a.mud_container.yang_nodes['ietf-mud:mud'].yang_nodes['to-device-policy']:getRootNode():getName(), "mud-container")

    nodes = yang.findNodes(sub, "/ietf-mud:mud/to-device-policy/access-lists/access-list[2]/name")
    expect = { "second-acl" }
    lu.assertEquals(yang.nodeListToData(nodes), expect)
  end
-- class testMud


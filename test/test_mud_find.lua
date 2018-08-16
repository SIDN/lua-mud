#!/usr/bin/lua

local mu = require("mudv2")
local lu = require("luaunit")
local yang = require("yang")

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
    --self.a:print()
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

  function TestMudFind:testFindNodes()
    -- this one is buggy from the looks of it
    --local some_sub_node = self.a.mud_container:getNode('ietf-access-control-list:acls/acl[1]/name')

    --print_find_result(self.a.mud_container, "/foo")
    --print_find_result(self.a.mud_container, "/ietf-mud:mud")
    print_find_result(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list[*]")
    --print_find_result(self.a.mud_container, "/ietf-mud:mud/to-device-policy/access-lists/access-list[1]/name")
  end
-- class testMud


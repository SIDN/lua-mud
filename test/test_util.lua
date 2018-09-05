#!/usr/bin/lua

local lu = require("luaunit")
local yang = require("yang")

local json = require("cjson")

TestUtil = {} --class
  function TestUtil:setup()
  end

  function TestUtil:test_str_isplit()
    local input = "a,b,c"
    local expect = { [1] = "a", [2] = "b", [3] = "c" }
    local result = yang.util.str_isplit(input, "[^,]")
    lu.assertEquals(result, expect)
  end

  function TestUtil:str_split()
    local input = "a,b,c"
    local expect = { [1] = "a", [2] = "b", [3] = "c" }
    local result = yang.util.str_split(input, ",")
    lu.assertEquals(result, expect)

    input = ",c"
    expect = { [1] = "", [2] = "c" }
    result = yang.util.str_split(input, ",")
    lu.assertEquals(result, expect)

    input = "foobarbaz"
    expect = { [1] = "foo", [2] = "baz" }
    result = yang.util.str_split(input, "bar")
    lu.assertEquals(result, expect)
  end

  function TestUtil:test_str_join()
    local input = { [1] = "a", [2] = "b", [3] = "c" }
    local expect = "a,b,c"
    local result = yang.util.str_join(",", input)
    lu.assertEquals(result, expect)

    lu.assertEquals(yang.util.str_join("", {}), "")
  end

  function TestUtil:test_split_one()
    local input = "a,b,c"
    local expect1 = "a"
    local expect2 = "b,c"
    local result1, result2 = yang.util.str_split_one(input, ",")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "a,b,c"
    expect1 = nil
    expect2 = "a,b,c"
    result1, result2 = yang.util.str_split_one(input, "nomatch")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "a,b,c"
    expect1 = ""
    expect2 = ",c"
    result1, result2 = yang.util.str_split_one(input, "a,b")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "a,b,c"
    expect1 = "a,"
    expect2 = ""
    result1, result2 = yang.util.str_split_one(input, "b,c")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "foo/bar[1]/baz"
    expect1 = "foo"
    expect2 = "bar[1]/baz"
    result1, result2 = yang.util.str_split_one(input, "/")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)
  end

  function TestUtil:test_get_path_list_index()
    local input, list_name, list_index

    input = "foo[1]/bar/baz"
    list_name, list_index = get_path_list_index(input)
    lu.assertEquals(list_name, "foo")
    lu.assertEquals(list_index, 1)

    input = "bar[2]"
    list_name, list_index = get_path_list_index(input)
    lu.assertEquals(list_name, "bar")
    lu.assertEquals(list_index, 2)

    input = "foo/bar/baz"
    list_name, list_index = get_path_list_index(input)
    lu.assertEquals(list_name, nil)
    lu.assertEquals(list_index, nil)

    input = "foo/bar[1]/baz"
    list_name, list_index = get_path_list_index(input)
    lu.assertEquals(list_name, nil)
    lu.assertEquals(list_index, nil)
  end

  function TestUtil:test_get_index_of()
    local list = { [1] = "a", [2] = "b", [3] = "c" }
    lu.assertEquals(yang.util.get_index_of(list, "a"), 1)
    lu.assertEquals(yang.util.get_index_of(list, "b"), 2)
    lu.assertEquals(yang.util.get_index_of(list, "c"), 3)
    lu.assertError(yang.util.get_index_of, list, "d")
  end

  function TestUtil:test_tdump()
    yang.util.tdump({})
  end

  --function TestUtil:test_other_split()
  --  local input = "foo/bar[0]/baz"
  --
  --end
-- class testUtil



TestOrderedDict = {} --class
  function TestOrderedDict:setup()
    self.od = yang.util.OrderedDict.create()
  end

  function TestOrderedDict:test_assign()
    lu.assertEquals(self.od["a"], nil)
    self.od["a"] = 1
    lu.assertEquals(self.od["a"], 1)
    self.od["a"] = 2
    lu.assertEquals(self.od["a"], 2)
    self.od["b"] = 3
    self.od["c"] = 4
    lu.assertEquals(self.od["a"], 2)
    lu.assertEquals(self.od["b"], 3)
    lu.assertEquals(self.od["c"], 4)
  end

  function TestOrderedDict:test_size()
    lu.assertEquals(self.od:size(), 0)
    self.od["a"] = "foo"
    lu.assertEquals(self.od["a"], "foo")
    lu.assertEquals(table.getn(self.od.keys), 1)
    lu.assertEquals(self.od:size(), 1)
    self.od["b"] = "bar"
    lu.assertEquals(self.od:size(), 2)
    self.od["a"] = "baz"
    lu.assertEquals(self.od:size(), 2)
    self.od["a"] = nil
    lu.assertEquals(self.od:size(), 1)
  end

  function TestOrderedDict:test_order()
    local keys_a = { "a", "b", "c", "d" }
    local keys_b = { "d", "c", "b", "a" }
    local expected_values = { 11, 22, 33, 44}
    local odict = yang.util.OrderedDict.create()

    for i,key in pairs(keys_a) do
      odict[key] = expected_values[i]
    end

    local values = {}
    for i,v in odict:iterate() do
      table.insert(values, v)
    end
    
    lu.assertEquals(values, expected_values)

    -- now add the same values, but reverse the keys
    -- a normal dict would have switched one of these around
    odict = yang.util.OrderedDict.create()
    for i,key in pairs(keys_b) do
      odict[key] = expected_values[i]
    end

    local values = {}
    for i,v in odict:iterate() do
      table.insert(values, v)
    end
    
    lu.assertEquals(values, expected_values)
    
  end
-- class testOrderedDict

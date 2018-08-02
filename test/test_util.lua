#!/usr/bin/lua

local mu = require("yang_types")
local lu = require("luaunit")

local json = require("cjson")

TestUtil = {} --class
  function TestUtil:setup()
  end

  function TestUtil:test_str_isplit()
    local input = "a,b,c"
    local expect = { [1] = "a", [2] = "b", [3] = "c" }
    local result = str_isplit(input, "[^,]")
    lu.assertEquals(result, expect)
  end

  function TestUtil:test_str_split()
    local input = "a,b,c"
    local expect = { [1] = "a", [2] = "b", [3] = "c" }
    local result = str_split(input, ",")
    lu.assertEquals(result, expect)

    input = ",c"
    expect = { [1] = "", [2] = "c" }
    result = str_split(input, ",")
    lu.assertEquals(result, expect)

    input = "foobarbaz"
    expect = { [1] = "foo", [2] = "baz" }
    result = str_split(input, "bar")
    lu.assertEquals(result, expect)
  end

  function TestUtil:test_str_join()
    local input = { [1] = "a", [2] = "b", [3] = "c" }
    local expect = "a,b,c"
    local result = str_join(",", input)
    lu.assertEquals(result, expect)
  end

  function TestUtil:test_split_one()
    local input = "a,b,c"
    local expect1 = "a"
    local expect2 = "b,c"
    local result1, result2 = str_split_one(input, ",")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "a,b,c"
    expect1 = nil
    expect2 = "a,b,c"
    result1, result2 = str_split_one(input, "nomatch")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "a,b,c"
    expect1 = ""
    expect2 = ",c"
    result1, result2 = str_split_one(input, "a,b")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "a,b,c"
    expect1 = "a,"
    expect2 = ""
    result1, result2 = str_split_one(input, "b,c")
    lu.assertEquals(result1, expect1)
    lu.assertEquals(result2, expect2)

    input = "foo/bar[1]/baz"
    expect1 = "foo"
    expect2 = "bar[1]/baz"
    result1, result2 = str_split_one(input, "/")
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

  --function TestUtil:test_other_split()
  --  local input = "foo/bar[0]/baz"
  --  
  --end
-- class testUtil


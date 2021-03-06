#!/usr/bin/lua

local yang = require("mud.yang")
local lu = require('luaunit')
local json = require('cjson')

-- create a fake basic type for the first set of tests
local test_type = yang.util.subClass('test', yang.basic_types.YangNode)
local test_type_mt = { __index = test_type }
  function test_type:create(nodeName, mandatory)
    local new_inst = yang.basic_types.YangNode:create("test_type", nodeName, mandatory)
    setmetatable(new_inst, test_type_mt)
    return new_inst
  end
-- end of test_type

TestBasicType = {}
    function TestBasicType:setup()
      self.a = test_type:create('testtype', 'aaa', 'bb')
    end

    function TestBasicType:testBasicTypeErrors()
      lu.assertError(self.a.setValue, self, "asdf")
      lu.assertError(self.a.validate, self)
      lu.assertError(self.a.getNode, self, "/foo")
    end

    function TestBasicType:testGetPath()
      lu.assertEquals(self.a:getPath(), "testtype")
    end
-- class TestBasicType

TestUInt8 = {} --class
    function TestUInt8:setup()
      self.a = yang.basic_types.uint8:create('a')
      self.b = yang.basic_types.uint8:create('b')
    end

    function TestUInt8:testDefaults()
      lu.assertEquals(self.a:getType(), "uint8")
      lu.assertEquals(self.a:getName(), 'a')
      lu.assertEquals(self.b:getName(), 'b')
      lu.assertEquals(self.a:getValue(), nil)
    end

    function TestUInt8:testSet()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      self.a:setValue(200)
      lu.assertEquals(self.a:getValue(), 200)

      lu.assertEquals(self.b:getValue(), nil)
      self.b:setValue(1)
      lu.assertEquals(self.b:getValue(), 1)
      self.b:setValue(200)
      lu.assertEquals(self.b:getValue(), 200)

      lu.assertEquals(self.a:getValue(), 200)

      self.a:clearData()
      lu.assertEquals(self.a:getValue(), nil)
      self.b:clearData()
      lu.assertEquals(self.b:getValue(), nil)
    end

    function TestUInt8:testBadValues()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      lu.assertError(self.a.setValue, self.a, "a")
      lu.assertError(self.a.setValue, self.a, 300)
      lu.assertError(self.a.setValue, self.a, -1)
      lu.assertEquals(self.a:getValue(), 1)
    end
-- class TestUint8

TestUint16 = {} --class
    function TestUint16:setup()
      self.a = yang.basic_types.uint16:create('a')
      self.b = yang.basic_types.uint16:create('b')
    end

    function TestUint16:testDefaults()
      lu.assertEquals(self.a:getType(), "uint16")
      lu.assertEquals(self.a:getName(), 'a')
      lu.assertEquals(self.b:getName(), 'b')
      lu.assertEquals(self.a:getValue(), nil)
    end

    function TestUint16:testSet()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      self.a:setValue(200)
      lu.assertEquals(self.a:getValue(), 200)

      lu.assertEquals(self.b:getValue(), nil)
      self.b:setValue(1)
      lu.assertEquals(self.b:getValue(), 1)
      self.b:setValue(200)
      lu.assertEquals(self.b:getValue(), 200)
      lu.assertEquals(self.a:getValue(), 200)

      self.b:setValue(300)
      lu.assertEquals(self.b:getValue(), 300)

      self.a:clearData()
      lu.assertEquals(self.a:getValue(), nil)
      self.b:clearData()
      lu.assertEquals(self.b:getValue(), nil)
    end

    function TestUint16:testBadValues()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      lu.assertError(self.a.setValue, self.a, "a")
      lu.assertError(self.a.setValue, self.a, 70000)
      lu.assertError(self.a.setValue, self.a, -1)
      lu.assertEquals(self.a:getValue(), 1)
      self.a:clearData()
      lu.assertEquals(self.a:getValue(), nil)
    end
-- class TestUint16

TestUint32 = {} --class
    function TestUint32:setup()
      self.a = yang.basic_types.uint32:create('a')
      self.b = yang.basic_types.uint32:create('b')
    end

    function TestUint32:testDefaults()
      lu.assertEquals(self.a:getType(), "uint32")
      lu.assertEquals(self.a:getName(), 'a')
      lu.assertEquals(self.b:getName(), 'b')
      lu.assertEquals(self.a:getValue(), nil)
    end

    function TestUint32:testSet()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      self.a:setValue(200)
      lu.assertEquals(self.a:getValue(), 200)

      lu.assertEquals(self.b:getValue(), nil)
      self.b:setValue(1)
      lu.assertEquals(self.b:getValue(), 1)
      self.b:setValue(200)
      lu.assertEquals(self.b:getValue(), 200)
      lu.assertEquals(self.a:getValue(), 200)

      self.b:setValue(70000)
      lu.assertEquals(self.b:getValue(), 70000)

      self.a:clearData()
      lu.assertEquals(self.a:getValue(), nil)
      self.b:clearData()
      lu.assertEquals(self.b:getValue(), nil)
    end

    function TestUint32:testBadValues()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      lu.assertError(self.a.setValue, self.a, "a")
      lu.assertError(self.a.setValue, self.a, 5000000000)
      lu.assertError(self.a.setValue, self.a, -1)
      lu.assertEquals(self.a:getValue(), 1)
    end
-- class TestUint32

TestBoolean = {}
  function TestBoolean:setup()
    self.a = yang.basic_types.boolean:create('a')
    self.b = yang.basic_types.boolean:create('b')
  end

  function TestBoolean:testDefaults()
    lu.assertEquals(self.b:getType(), "boolean")
      lu.assertEquals(self.a:getName(), 'a')
      lu.assertEquals(self.b:getName(), 'b')
    lu.assertEquals(self.b:getValue(), nil)
  end

  function TestBoolean:testSet()
    lu.assertEquals(self.a:getValue(), nil)
    self.a:setValue(false)
    lu.assertEquals(self.a:getValue(), false)
    self.a:setValue(true)
    lu.assertEquals(self.a:getValue(), true)

    lu.assertEquals(self.b:getValue(), nil)
    self.b:setValue(false)
    lu.assertEquals(self.b:getValue(), false)
    self.b:setValue(true)
    lu.assertEquals(self.b:getValue(), true)

    lu.assertError(self.b.setValue, self, "asdf")
    lu.assertEquals(self.b:getValue(), true)

    self.b:clearData()
    lu.assertEquals(self.b:getValue(), nil)
  end
-- class TestBoolean

TestString = {}
  function TestString:setup()
    self.a = yang.basic_types.string:create('a')
    self.b = yang.basic_types.string:create('b')
  end

  function TestString:testDefaults()
    lu.assertEquals(self.a:getName(), 'a')
    lu.assertEquals(self.b:getName(), 'b')
  end

  function TestString:testSet()
    lu.assertEquals(self.a:getValue(), nil)
    self.a:setValue("foobar")
    lu.assertEquals(self.a:getValue(), "foobar")

    lu.assertNotEquals(self.a:getValue(), self.b:getValue())
    self.b:setValue("foobar")
    lu.assertEquals(self.a:getValue(), self.b:getValue())

    lu.assertError(self.b.setValue, self.b, 1)
  end
-- class TestString

TestContainer = {}
  function TestContainer:setup()
    self.a = yang.basic_types.container:create('a')
    self.a:add_node(yang.basic_types.uint16:create('number'), false)
    self.a:add_node(yang.basic_types.string:create('string'), false)
  end

  function TestContainer:testSet()
  end
-- class TestContainer

TestList = {}
  function TestList:setup()
    self.a = yang.basic_types.list:create('a')
    self.a:add_list_node(yang.basic_types.uint16:create('number'), false)
    self.a:add_list_node(yang.basic_types.string:create('string'), false)
  end

  function TestList:testGetSet()
    lu.assertEquals(self.a:getValue(), {})
    lu.assertEquals(self.a:hasValue(), false)

    local data = {[1]={number=123, string='example'}}
    self.a:fromData_noerror(data)
    lu.assertEquals(self.a:hasValue(), true)
    lu.assertEquals(self.a:toData(), data)
  end
-- class TestList

TestURI = {}
  function TestURI:setup()
    self.a = yang.basic_types.inet_uri:create('a')
    self.b = yang.basic_types.inet_uri:create('b')
  end

  function TestURI:testDefaults()
    lu.assertEquals(self.a:getType(), "inet_uri")
      lu.assertEquals(self.a:getName(), 'a')
      lu.assertEquals(self.b:getName(), 'b')
    lu.assertEquals(self.a:getValue(), nil)
  end

  function TestURI:testSet()
    lu.assertEquals(self.a:getValue(), nil)
    self.a:setValue("http://site.example/page")
    lu.assertEquals(self.a:getValue(), "http://site.example/page")
  end

  function TestURI:testBadValues()
    lu.assertEquals(self.a:getValue(), nil)
    self.a:setValue("ftp://site.example")
    lu.assertEquals(self.a:getValue(), "ftp://site.example")
    lu.assertError(self.a.setValue, self.a, "a")
    lu.assertError(self.a.setValue, self.a, 300)
    lu.assertError(self.a.setValue, self.a, -1)
    --lu.assertEquals(self.a:getValue(), 1)
    --self.a:setValue(1)
  end
-- class TestURI

TestDateTime = {}
  function TestDateTime:setup()
    self.a = yang.basic_types.date_and_time:create('a')
    self.b = yang.basic_types.date_and_time:create('b')
    self.c = yang.basic_types.date_and_time:create('c')
  end

  function TestDateTime:testSet()
    lu.assertEquals(self.a:getValue(), nil)
    self.a:setValue("2018-03-02T10:20:51+01:00")
    self.b:setValue("2018-03-02T10:20:51+01:00")
    self.c:setValue("2018-03-02T12:20:51+01:00")
    lu.assertEquals(self.a.date, self.b.date)
    lu.assertNotEquals(self.a.date, self.c.date)
    lu.assertNotEquals(self.b.date, self.c.date)
  end

  function TestDateTime:testBadValues()
    lu.assertEquals(self.a:getValue(), nil)
    lu.assertError(self.a.setValue, self.a, 1)
    lu.assertError(self.a.setValue, self.a, "foo")
    lu.assertEquals(self.a:getValue(), nil)

    -- make sure it doesn't modify the value if set fails
    self.a:setValue("2018-03-02T10:20:51+01:00")
    self.b:setValue("2018-03-02T10:20:51+01:00")
    lu.assertEquals(self.a.date, self.b.date)
    lu.assertError(self.a.setValue, self.a, "foo")
    lu.assertEquals(self.a.date, self.b.date)
  end
-- class TestDateTime


TestMacAddress = {}
  function TestMacAddress:setup()
    self.a = yang.basic_types.mac_address:create('a')
    self.b = yang.basic_types.mac_address:create('b')
    self.c = yang.basic_types.mac_address:create('c')
  end

  function TestMacAddress:testSet()
    lu.assertEquals(self.a:getValue(), nil)
    self.a:setValue("aa:bb:cc:dd:ee:ff")
    lu.assertEquals(self.a:getValue(), "aa:bb:cc:dd:ee:ff")
    self.a:setValue("00:11:22:33:44:55")
    lu.assertEquals(self.a:getValue(), "00:11:22:33:44:55")
    lu.assertError(self.a.setValue, self.a, "foobar")
    lu.assertEquals(self.a:getValue(), "00:11:22:33:44:55")
    lu.assertError(self.a.setValue, self.a, 1)
    lu.assertEquals(self.a:getValue(), "00:11:22:33:44:55")
  end
-- class TestMacAddress



TestACL = {}
  function TestACL:setup()
    self.a = yang.complex_types.acl_type:create('a')
  end

  function TestACL:testSet()
    lu.assertEquals(self.a:getValue(), nil)
    lu.assertError(self.a.setValue, self.a, 123)
    lu.assertEquals(self.a:getValue(), nil)

    local data = "aaaa"
    lu.assertError(self.a.setValue, self.a, data)
  end
-- class TestACL

TestIPv4Prefix = {}
  function TestIPv4Prefix:setup()
    self.a = yang.complex_types.inet_ipv4_prefix:create('prefix')
  end

  function TestIPv4Prefix:testGoodAddresses()
    self.a:fromData_noerror("192.0.2.0/32")
    self.a:fromData_noerror("192.0.2.0/24")
    self.a:fromData_noerror("192.0.2.0/8")
    self.a:fromData_noerror("1.1.1.1/8")
    self.a:fromData_noerror("255.255.255.255/0")
  end

  function TestIPv4Prefix:testBadAddresses()
    lu.assertError(self.a.fromData, self.a, "256.0.2.0/32")
    lu.assertError(self.a.fromData, self.a, "192.0.2.0/33")
    lu.assertError(self.a.fromData, self.a, "192.0.2.0/-1")
    lu.assertError(self.a.fromData, self.a, "-1.0.2.0/32")
    lu.assertError(self.a.fromData, self.a, "a1.2.3.4/24")
    lu.assertError(self.a.fromData, self.a, "1.2.3.4/a")
  end
-- class TestIPv4Prefix

TestIPv6Prefix = {}
  function TestIPv6Prefix:setup()
    self.a = yang.complex_types.inet_ipv6_prefix:create('prefix')
  end

  function TestIPv6Prefix:testGoodAddresses()
    self.a:fromData_noerror("2001:DB8::/32")
    self.a:fromData_noerror("2001:DB8::1/128")
    self.a:fromData_noerror("2001:DB8:aa11:11aa:12:ad:ff:1/128")
    self.a:fromData_noerror("::/128")
  end

  function TestIPv6Prefix:testBadAddresses()
    lu.assertError(self.a.fromData, self.a, "")
    lu.assertError(self.a.fromData, self.a, "aaa")
    lu.assertError(self.a.fromData, self.a, "2001:DB8/128")
    lu.assertError(self.a.fromData, self.a, "2001:DB8::/129")
    lu.assertError(self.a.fromData, self.a, "2001:DB8::/")
    lu.assertError(self.a.fromData, self.a, "2001:DB8::/a")
    lu.assertError(self.a.fromData, self.a, "2001:DB8::a:1::2:/32")
    lu.assertError(self.a.fromData, self.a, "2001:DB8:1::2::/32")
    lu.assertError(self.a.fromData, self.a, "2001:DB8::1:2::/32")
    lu.assertError(self.a.fromData, self.a, "2001:DB8::1:2::/32")
    lu.assertError(self.a.fromData, self.a, "::1::/32")
    lu.assertError(self.a.fromData, self.a, "2001:DB8:aa11:11aa:12:ad:ff:1:2:3:4/128")
    lu.assertError(self.a.fromData, self.a, "2001:DB8:aa11:11aa:12:ad:ff:1:2/128")
    lu.assertError(self.a.fromData, self.a, "2001:DB8:aa11:11aa:12:ad:ff:1:2/128")
    lu.assertError(self.a.fromData, self.a, "2001:Dg8::1/128")
    lu.assertError(self.a.fromData, self.a, "2001:DB812::1/128")
  end
-- class TestIPv6Prefix


TestChoice = {}
  function TestChoice:setup()
  end

  function TestChoice:testOne()
    local a = yang.basic_types.choice:create("my-choice", false)
    a:add_case_container("c1", yang.basic_types.string:create("a-string", false))
    a:add_case_container("c2", yang.basic_types.boolean:create("a-bool", false))
    a:add_case_container("c3", yang.basic_types.uint16:create("an-int", false))

    lu.assertEquals(a:hasValue(), false)
    lu.assertEquals(a:toData(), nil)

    local fromdata_result = a:fromData_noerror('data string')
    lu.assertEquals(fromdata_result, true)
    lu.assertEquals(a:hasValue(), true)
    lu.assertEquals(a:toData(), "data string")

    a:fromData_noerror(false)
    lu.assertEquals(a:hasValue(), true)
    lu.assertEquals(a:toData(), false)

    a:fromData_noerror(12345)
    lu.assertEquals(a:hasValue(), true)
    --lu.assertEquals(a:toData(), 12345)

    -- this one should not work, it should stay at the previous value
    a:fromData_noerror({['aaa']='bbb'})
    lu.assertEquals(a:hasValue(), true)
    --lu.assertEquals(a:toData(), 12345)

    a:clearData()
    lu.assertEquals(a:hasValue(), false)
    lu.assertEquals(a.active_case, nil)

  end

  function TestChoice:testContainerWithChoice()
    local c = yang.basic_types.container:create("my-container", false)
    local cc = yang.basic_types.choice:create("my-choice", false)

    local cc1c = yang.basic_types.container:create("choice-val-int", false)
    local cc1ci = yang.basic_types.uint32:create("choice-int", false)

    local cc2c = yang.basic_types.container:create("choice-val-bool", false)
    local cc2ci = yang.basic_types.boolean:create("choice-bool", false)

    cc1c:add_node(cc1ci)
    cc:add_case_container("choice-val-int", cc1ci)

    cc2c:add_node(cc2ci)
    cc:add_case_container("l2", cc2ci)

    c:add_node(cc)

    local data_int = json.decode('{"my-container": { "choice-int": 4 } }')
    local data_bool = json.decode('{"my-container": { "choice-bool": false } }')
    c:fromData_noerror(data_int)
    c:fromData_noerror(data_bool)
  end

  function TestChoice:temp()
  end

function TestChoice:FOO()
    local cc1 = yang.basic_types.choice:create("my-first-choice", false)
    -- TODO: make these cases instead of plain containers, to prevent confusion?
    local cc1a = yang.basic_types.container:create("first-choice-container-one", false)
    local cc1b = yang.basic_types.container:create("first-choice-container-two", false)

    cc1a:add_node(yang.basic_types.uint16:create('an-int'), false)

    local cc1bc = yang.basic_types.choice:create("my-second-choice", false)
    --local cc1bc1 = yang.basic_types.container:create('second-choice-int-container', false)
    --cc1bc1:add_node()
    cc1bc:add_case_container('second-choice-integer', yang.basic_types.uint16:create('second-choice-int', false))

    local cc1bc2 = yang.basic_types.container:create('second-choice-bool-container', false)
    cc1bc2:add_node(yang.basic_types.boolean:create('second-choice-bool', false))
    cc1bc:add_case_container('second-choice-boolean', cc1bc2)
    cc1b:add_node(cc1bc)

    cc1:add_case_container('first-choice', cc1a)
    cc1:add_case_container('second-choice', cc1b)
end

  function TestChoice:testChoiceInChoice()
    -- Choice nodes themselves are not represented in the data.
    local c = yang.basic_types.container:create("my-container", false)

    local choice_one = yang.basic_types.choice:create("my-first-choice", false)

    -- The first choice has one case: a container 'an-int' with an integer value
    local choice_one_case = yang.basic_types.container:create("an-int", false)
    local choice_one_case_data = yang.basic_types.uint16:create('an-int', false)
    choice_one_case:add_node(choice_one_case_data)
    choice_one:add_case_container("an-int", choice_one_case)

    c:add_node(choice_one)

    -- The second choice has two cases: the first is a direct string
    -- The second is yet another choice, an int or a bool
    local choice_two = yang.basic_types.choice:create("my-second-choice", false)
    choice_two:add_case_container("direct-string", yang.basic_types.string:create("string-opt", false))

    local subchoice = yang.basic_types.choice:create("my-third-choice", false)
    subchoice:add_case_container("a-bool", yang.basic_types.boolean:create("bool-opt", false))
    subchoice:add_case_container("an-octet", yang.basic_types.uint8:create("an-octet", false))
    choice_two:add_case_container("subchoice", subchoice)
    
    c:add_node(choice_two)
    local data = {}

    --lu.assertEquals(c:toData(), {})

    -- top-level tests
    data = json.decode('{ "my-first-choice": { "an-int": 4 } }')
    c:fromData_noerror(data)
    lu.assertEquals(c:toData(), data)

    c:clearData()
    lu.assertEquals(c:toData(), nil)

    data = json.decode('{ "my-second-choice": "foobar" }')
    c:fromData_noerror(data)
    lu.assertEquals(c:toData(), data)

    data = json.decode('{ "my-second-choice": true }')
    c:fromData_noerror(data)
    lu.assertEquals(c:toData(), data)

    data = json.decode('{ "my-second-choice": 8 }')
    c:fromData_noerror(data)
    lu.assertEquals(c:toData(), data)

    c:clearData()
    lu.assertEquals(c:toData(), nil)

    -- 300 > 255 so this should fail (no choice match)
    data = json.decode('{ "my-second-choice": 300 }')
    c:fromData_noerror(data)
    lu.assertEquals(c:toData(), nil)


    -- try the choice nodes directly
    data = json.decode('{ "an-int": 4 }')
    choice_one:fromData_noerror(data)
    lu.assertEquals(choice_one:toData(), data)

    c:clearData()

    data = true
    choice_two:fromData_noerror(data)
    lu.assertEquals(choice_two:toData(), data)

    c:clearData()

    data = 255
    choice_two:fromData_noerror(data)
    lu.assertEquals(choice_two:toData(), data)

    data = 257
    choice_two:fromData_noerror(data)
    lu.assertEquals(choice_two:toData(), 255)

    c:clearData()
    lu.assertEquals(c:toData(), nil)

  end
-- class TestChoice





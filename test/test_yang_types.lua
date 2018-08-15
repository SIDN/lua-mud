#!/usr/bin/lua

local yang = require "yang"
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
    end

    function TestUint16:testBadValues()
      lu.assertEquals(self.a:getValue(), nil)
      self.a:setValue(1)
      lu.assertEquals(self.a:getValue(), 1)
      lu.assertError(self.a.setValue, self.a, "a")
      lu.assertError(self.a.setValue, self.a, 70000)
      lu.assertError(self.a.setValue, self.a, -1)
      lu.assertEquals(self.a:getValue(), 1)
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
    self.a:fromData(data)
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
-- class TestMacAddress




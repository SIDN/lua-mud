#!/usr/bin/lua

local yang = require "yang"
local lu = require('luaunit')

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

  function TestBoolean:setSet()
    lu.assertEquals(self.a.getValue(), nil)
    self.a.setValue(false)
    lu.assertEquals(self.a:getValue(), false)
    self.a.setValue(true)
    lu.assertEquals(self.a:getValue(), true)

    lu.assertEquals(self.b:getValue(), true)
    self.b.setValue(false)
    lu.assertEquals(self.b:getValue(), false)
    self.b.setValue(true)
    lu.assertEquals(self.b:getValue(), true)
  end
-- class TestBoolean

TestURI = {}
  function TestURI:setup()
    self.a = yang.basic_types.inet_uri:create('a')
    self.b = yang.basic_types.inet_uri:create('b')
  end

  function TestURI:testDefaults()
    lu.assertEquals(self.a:getType(), "inet:uri")
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

TestString = {}
  function TestString:setup()
    self.a = yang.basic_types.string:create('a')
    self.b = yang.basic_types.string:create('b')
  end

  function TestString:testDefaults()
    lu.assertEquals(self.a:getName(), 'a')
    lu.assertEquals(self.b:getName(), 'b')
  end

  function TestString:setValue()
    lu.assertEquals(self.a:getValue(), nil)
    self.a.setValue("foobar")
    lu.assertEquals(self.a:getValue(), "foobar")

    lu.assertNotEquals(self.a:getValue(), self.b.getValue())
    self.b.setValue("foobar")
    lu.assertEquals(self.a:getValue(), self.b.getValue())
  end
-- class TestString

--lu.run()


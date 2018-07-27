#!/usr/bin/lua

local yt = require "yang_types"
local lu = require('luaunit')

TestUInt8 = {} --class
    function TestUInt8:setup()
      self.a = yt.uint8.create()
      self.b = yt.uint8.create()
    end

    function TestUInt8:testDefaults()
      lu.assertEquals(self.a:getType(), "uint8")
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
    self.a = yt.boolean.create()
    self.b = yt.boolean.create()
  end

  function TestBoolean:testDefaults()
    lu.assertEquals(self.b:getType(), "boolean")
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
    self.a = yt.inet_uri.create()
    self.b = yt.inet_uri.create()
  end

  function TestURI:testDefaults()
    lu.assertEquals(self.a:getType(), "inet:uri")
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

lu.run()

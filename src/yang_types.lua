local url = require("socket.url")

local _M = {}
-- helper classes for the basic types used in YANG
-- These classes take care of validation of values, basic conversion,
-- and optional additional helper functions (such as getHostName for inet:uri)
--
-- The convention for naming is:
-- - type/class names correspond with the YANG name, except for hyphens and colons
-- - hyphens are changed to a single underscore
-- - colons are changed to a double underscore
--
-- Examples:
-- yang type uint8 stays uint8
-- yang type inet:uri becomes inet__uri

-- Taken from http://lua-users.org/wiki/InheritanceTutorial
-- Defining a class with inheritsFrom instead of just {} will
-- add all methods, and class, superclass and isa method
function inheritsFrom( baseClass )

    local new_class = {}
    local class_mt = { __index = new_class }

    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    if nil ~= baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    -- Implementation of additional OO properties starts here --

    -- Return the class object of the instance
    function new_class:class()
        return new_class
    end

    -- Return the super class object of the instance
    function new_class:superClass()
        return baseClass
    end

    -- Return true if the caller is an instance of theClass
    function new_class:isa( theClass )
        local b_isa = false

        local cur_class = new_class

        while ( nil ~= cur_class ) and ( false == b_isa ) do
            if cur_class == theClass then
                b_isa = true
            else
                cur_class = cur_class:superClass()
            end
        end

        return b_isa
    end

    return new_class
end


local BaseType = {}
BaseType_mt = { __index = BaseType }
  function BaseType:create(typeName)
    local new_inst = {}
    setmetatable(new_inst, BaseType)
    new_inst.value = nil
    new_inst.typeName = typeName
    return new_inst
  end

  function BaseType:getType()
    return self.typeName
  end

  function BaseType:getValue(value)
    return self.value
  end
-- class BaseType not exported


local uint8 = inheritsFrom(BaseType)
uint8_mt = { __index = uint8 }
  function uint8:create()
    local new_inst = BaseType:create("uint8")
    setmetatable(new_inst, uint8_mt)
    return new_inst
  end

  function uint8:setValue(value)
    if type(value) == 'number' then
      if value < 0 or value > 255 then
        error("value for " .. set.getType() .. " out of range: " .. value)
      else
        self.value = value
      end
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of number")
    end
  end
_M.uint8 = uint8

local boolean = inheritsFrom(BaseType)
boolean_mt = { __index = boolean }
  function boolean:create()
    local new_inst = BaseType:create("boolean")
    setmetatable(new_inst, boolean_mt)
    return new_inst
  end

  function boolean:setValue(value)
    if type(value) == 'boolean' then
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of boolean")
    end
  end
_M.boolean = boolean

local inet_uri = inheritsFrom(BaseType)
inet_uri_mt = { __index = inet_uri }
  function inet_uri:create()
    local new_inst = BaseType:create("inet:uri")
    setmetatable(new_inst, inet_uri_mt)
    return new_inst
  end

  function inet_uri:setValue(value)
    if type(value) == 'string' then
      self.uri_parts = url.parse(value, nil)
      --print("[XX] " .. self.uri_parts['url'])
      if self.uri_parts == nil or self.uri_parts['host'] == nil then
        error("value for " .. self:getType() .. ".setValue() is not a valid URI")
      end
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.inet_uri = inet_uri



return _M

local url = require("socket.url")
local luadate = require("date")

local json = require("cjson")

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

-- helper function for deep copying data elements
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local BaseType = {}
BaseType_mt = { __index = BaseType }
  function BaseType:create(typeName, mandatory)
    local new_inst = {}
    setmetatable(new_inst, BaseType)
    new_inst.value = nil
    new_inst.typeName = typeName
    if mandatory ~= nil then
      new_inst.mandatory = mandatory
    else
      new_inst.mandatory = true
    end
    return new_inst
  end

  function BaseType:getType()
    return self.typeName
  end

  function BaseType:getValue()
    return self.value
  end

  function BaseType:getValueAsString()
    return tostring(self.value)
  end

  function BaseType:hasValue(value)
    return self.value ~= nil
  end

  function BaseType:setValue(value)
    error("setValue needs to be implemented in subclass")
  end

  function BaseType:validate()
    error("validate needs to be implemented in subclass")
  end

  function BaseType:isMandatory()
    return self.mandatory
  end

  -- note: this 'json_data' is already read with json.decode()!
  -- (so it is not, in fact, json data)
  -- maybe make it 'fromData' or 'fromBasicData' or something?
  -- what does one call data comprising only basic language types
  function BaseType:fromData(json_data)
    -- for basic types, we simply use setValue (which contains the correct checks)
    self:setValue(json_data)
  end
-- class BaseType not exported


local uint8 = inheritsFrom(BaseType)
uint8_mt = { __index = uint8 }
  function uint8:create(mandatory)
    local new_inst = BaseType:create("uint8", mandatory)
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
  function boolean:create(mandatory)
    local new_inst = BaseType:create("boolean", mandatory)
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
  function inet_uri:create(mandatory)
    local new_inst = BaseType:create("inet:uri", mandatory)
    setmetatable(new_inst, inet_uri_mt)
    return new_inst
  end

  function inet_uri:setValue(value)
    if type(value) == 'string' then
      self.uri_parts = url.parse(value, nil)
      if self.uri_parts == nil or self.uri_parts['host'] == nil then
        error("value for " .. self:getType() .. ".setValue() is not a valid URI: " .. value)
      end
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.inet_uri = inet_uri

local yang_date_and_time = inheritsFrom(BaseType)
yang_date_and_time_mt = { __index = yang_date_and_time }
  function yang_date_and_time:create(mandatory)
    local new_inst = BaseType:create("yang:date-and-time", mandatory)
    setmetatable(new_inst, yang_date_and_time_mt)
    return new_inst
  end

  function yang_date_and_time:setValue(value)
    if type(value) == 'string' then
      local success, result = pcall(luadate, value)
      if not success then
        error("value for " .. self:getType() .. ".setValue() is not a valid datetime: " .. result)
      end
      self.date = result
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.yang_date_and_time = yang_date_and_time


local string = inheritsFrom(BaseType)
string_mt = { __index = string }
  function string:create(mandatory)
    local new_inst = BaseType:create("string", mandatory)
    setmetatable(new_inst, string_mt)
    return new_inst
  end

  function string:setValue(value)
    if type(value) == 'string' then
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of number")
    end
  end
_M.string = string

local notimplemented = inheritsFrom(BaseType)
notimplemented_mt = { __index = notimplemented }
  function notimplemented:create(mandatory)
    local new_inst = BaseType:create("notimplemented", mandatory)
    setmetatable(new_inst, notimplemented_mt)
    return new_inst
  end

  function notimplemented:setValue(value)
    error("Not implemented")
  end
_M.notimplemented = notimplemented

--

local acl_type = inheritsFrom(BaseType)
acl_type_mt = { __index = acl_type }
  function acl_type:create(mandatory)
    local new_inst = BaseType:create("acl-type", mandatory)
    setmetatable(new_inst, acl_type_mt)
    return new_inst
  end

  function acl_type:setValue(value)
    if type(value) == 'string' then
      -- TODO: rest of types. do we need to keep enumeration lists centrally?
      if value == "ipv4-acl-type" or
         value == "ipv6-acl-type" then
        self.value = value
      else
        error("type error: " .. self:getType() .. ".setValue() with unknown acl type: '" .. value .. "'")
      end
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.acl_type = acl_type

-- a container is the general-purpose holder of data that is not of any specific type
-- essentially, it's the 'main' holder of definitions and data
local container = inheritsFrom(BaseType)
container_mt = { __index = container }
  function container:create(mandatory)
    local new_inst = BaseType:create("container", mandatory)
    setmetatable(new_inst, container_mt)
    new_inst.yang_elements = {}
    -- a container's value is contained in its yang elements
    new_inst.value = nil
    return new_inst
  end

  function container:add_yang_element(element_name, element_type_instance)
    self.yang_elements[element_name] = element_type_instance
  end

  function container:fromData(json_data)
    for element_name, element in pairs(self.yang_elements) do
      print("Trying yang element " .. element_name)
      if json_data[element_name] ~= nil then
        element:fromData(json_data[element_name])
      elseif element:isMandatory() then
        error('mandatory element ' .. element_name .. ' not found in: ' .. json.encode(json_data[element_name]))
      --else
      --  print("[XX] element with name " .. element_name .. " has no value but not mandatory: " .. json.encode(element:isMandatory()))
      end
    end
  end

  function container:print()
    for element_name, element in pairs(self.yang_elements) do
      if element:hasValue() then
        print(element_name .. ": " .. element:getValueAsString())
      else
        print(element_name .. ": <not set>")
      end
    end
  end
_M.container = container

-- we implement lists by making them lists of containers, with
-- an interface that skips the container part (mostly)
local list = inheritsFrom(BaseType)
list_mt = { __index = list }
  function list:create()
    local new_inst = BaseType:create("list")
    setmetatable(new_inst, list_mt)
    new_inst.entry_elements = {}
    -- value is a table of entries, each of which should conform to
    -- the specification of entry_elements
    new_inst.value = {}
    return new_inst
  end

  function list:set_entry_element(name, element_type_instance)
    self.entry_elements[name] = element_type_instance
  end

  function list:add_element()
    local new_element = container:create()
    -- TODO: should this be a deep copy?
    new_element.yang_elements = deepcopy(self.entry_elements)
    print("[XX] NEW ELEMENT" .. json.encode(new_element.yang_elements))
    --new_element.value = nil
    table.insert(self.value, new_element)
    return new_element
  end
  -- TODO: should we error on attempts to use getValue and setValue?

  function list:fromData(data)
    -- TODO: should we empty our local data to be sure at this point?
    for i,data_el in pairs(data) do
      local new_el = self:add_element()
      new_el:fromData(data_el)
    end
  end

  function list:getValueAsString()
    local result = "[\n"
    for i,v in pairs(self.value) do
      result = result .. "{\n"
      for name,ye in pairs(v.yang_elements) do
        result = result .. "  " .. name .. ": " .. ye:getValueAsString() .. ",\n"
      end
      result = result .. "\n},\n"
    end
    result = result .. "\n]\n"
    return result
  end

  function list:print()
    print(self:getValueAsString())
  end
_M.list = list

return _M


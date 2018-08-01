local url = require("socket.url")
local luadate = require("date")

local json = require("cjson")

-- ponderings (TODO)
--
-- Should we make a (global?) type registry, and just treat everything as a type?
-- e.g. augmentations, and basic types, etc.
--
-- in code, we can make an augmentation by simply inheritFrom (see also
-- how we define top-level definitions, we inheritFrom container there)
--
-- do we need basic enumtypes and identitytypes?
--

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
    -- complex types should override this method
    self:setValue(json_data)
  end

  -- returns the current value as native data; for simple types, this
  -- is just the value itself
  function BaseType:toData()
    return self.value
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

local uint16 = inheritsFrom(BaseType)
uint16_mt = { __index = uint16 }
  function uint16:create(mandatory)
    local new_inst = BaseType:create("uint16", mandatory)
    setmetatable(new_inst, uint16_mt)
    return new_inst
  end

  function uint16:setValue(value)
    if type(value) == 'number' then
      if value < 0 or value > 65535 then
        error("value for " .. set.getType() .. " out of range: " .. value)
      else
        self.value = value
      end
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of number")
    end
  end
_M.uint16 = uint16

local uint32 = inheritsFrom(BaseType)
uint32_mt = { __index = uint32 }
  function uint32:create(mandatory)
    local new_inst = BaseType:create("uint32", mandatory)
    setmetatable(new_inst, uint32_mt)
    return new_inst
  end

  function uint32:setValue(value)
    if type(value) == 'number' then
      if value < 0 or value > 4294967295 then
        error("value for " .. set.getType() .. " out of range: " .. value)
      else
        self.value = value
      end
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of number")
    end
  end
_M.uint32 = uint32


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

local yang_mac_address = inheritsFrom(BaseType)
yang_mac_address_mt = { __index = yang_mac_address }
  function yang_mac_address:create(mandatory)
    local new_inst = BaseType:create("inet:uri", mandatory)
    setmetatable(new_inst, yang_mac_address_mt)
    return new_inst
  end

  function yang_mac_address:setValue(value)
    if type(value) == 'string' then
      if not string.match(value, "^%x%x:%x%x:%x%x:%x%x:%x%x:%x%x$") then
        error("value for " .. self:getType() .. ".setValue() is not a valid MAC address: " .. value)
      end
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.yang_mac_address = yang_mac_address

local eth_ethertype = inheritsFrom(BaseType)
eth_ethertype_mt = { __index = eth_ethertype }
  function eth_ethertype:create(mandatory)
    local new_inst = BaseType:create("inet:uri", mandatory)
    setmetatable(new_inst, eth_ethertype_mt)
    return new_inst
  end

  function eth_ethertype:setValue(value)
    error("NOTIMPL: eth:ethertype not implemented yet")
  end
_M.eth_ethertype = eth_ethertype

local inet_dscp = inheritsFrom(BaseType)
inet_dscp_mt = { __index = inet_dscp }
  function inet_dscp:create(mandatory)
    local new_inst = BaseType:create("inet:uri", mandatory)
    setmetatable(new_inst, inet_dscp_mt)
    return new_inst
  end

  function inet_dscp:setValue(value)
    error("NOTIMPL: inet:dscp not implemented yet")
  end
_M.inet_dscp = inet_dscp

local bits = inheritsFrom(BaseType)
bits_mt = { __index = bits }
  function bits:create(mandatory)
    local new_inst = BaseType:create("inet:uri", mandatory)
    setmetatable(new_inst, bits_mt)
    return new_inst
  end

  function bits:setValue(value)
    error("NOTIMPL: bits not implemented yet")
  end
_M.bits = bits


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
    if element_type_instance == nil then error("container:add_yang_element() called with nil element_type_instance") end
    self.yang_elements[element_name] = element_type_instance
  end

  function container:fromData(json_data, check_all_data_used)
    for element_name, element in pairs(self.yang_elements) do
      print("Trying yang element '" .. element_name .. "' (" .. element:getType() .. ")")
      if json_data[element_name] ~= nil then
        element:fromData(json_data[element_name])
        json_data[element_name] = nil
      elseif element:isMandatory() then
        --error('mandatory element ' .. element_name .. ' not found in: ' .. json.encode(json_data[element_name]))
        error('mandatory element ' .. element_name .. ' not found in: ' .. json.encode(json_data))
      --else
      --  print("[XX] element with name " .. element_name .. " has no value but not mandatory: " .. json.encode(element:isMandatory()))
      end
    end
    
    if json.encode(json_data) ~= "{}" then
      print("[XX] TABLE AFTER CONTAINER FROMDATA: " .. json.encode(json_data))
      error("Unhandled data: " .. json.encode(json_data))
    end
  end

  function container:print()
    print(self:getValueAsString())
  end

  function container:getValueAsString()
    result = "{ "
    for element_name, element in pairs(self.yang_elements) do
      if element:hasValue() then
        result = result .. "  " .. element_name .. ": " .. element:getValueAsString() .. "\n"
      else
        result = result .. "  " .. element_name .. ": <not set>\n"
      end
    end
    result = result .. "}\n"
    return result
  end

  function container:toData()
    local result = {}
    for name,value in pairs(self.yang_elements) do
      local v = value:toData()
      -- exclude empty elements
      if name == "eth" then
        error("yo")
      end
      if v ~= nil and (type(v) ~= table or tablelength(v) > 0) then
          result[name] = v
      end
      --  value:toData()
      --end
      --if tablelength(v) > 0 then result[name] = value:toData() end
    end
    return result
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
    local result = " <LIST> [\n"
    for i,v in pairs(self.value) do
      for name,ye in pairs(v.yang_elements) do
        result = result .. "  " .. name .. ": " .. ye:getValueAsString() .. ",\n"
      end
      result = result .. ",\n"
    end
    result = result .. "\n]\n"
    return result
  end

  function list:print()
    print(self:getValueAsString())
  end

  function list:toData()
    local result = {}
    for i,value in pairs(self.value) do
      table.insert(result, value:toData())
    end
    return result
  end
_M.list = list

-- TODO: remove
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- case is a type where one or more of the defined choices can be used
local case = inheritsFrom(BaseType)
case_mt = { __index = case }
  function case:create(mandatory)
    local new_inst = BaseType:create("case", mandatory)
    setmetatable(new_inst, case_mt)
    new_inst.cases = {}
    -- value is a table of entries, each of which should conform to
    -- the specification of entry_elements
    return new_inst
  end

--  function case:setValue(value)
--    -- do we need this?
--    error("Got setValue for: " .. json.encode(value))
--  end

  function case:add_case(name, element_type)
    self.cases[name] = element_type
    print("[XX] ADDED CASE FOR " .. name .. " size now: " .. tablelength(self.cases))
  end

  function case:fromData(data)
    print("[XX] CASE fromData() data: " .. json.encode(data))
    for data_name, data_data in pairs(data) do
      print("[XX] looking for " .. data_name)
      print("[XX] my data is: " .. json.encode(data_data))
      local found = false
      for name,element_type in pairs(self.cases) do
        print("[XX] found: " .. name)
        if name == data_name then
          print("[XX] element_type mandatory: " .. element_type:getType() .. " " .. json.encode(element_type:isMandatory()))
          element_type:fromData(data_data)
          found = true
        end
        -- todo: improve error
      end
      if not found then error("Unknown case value: " .. data_name) end
    end
  end

  function case:toData(data)
    local result = {}
    print("[XX] toData on case")
    for name,element in pairs(self.cases) do
      print("[XX] trying case " .. name .. " in toData")
      -- TODO: do we need a hasValue() check for all types?
      --if element:getValue() ~= nil then
      print("[XX] RAW DATA: " .. json.encode(element))
      print("[XX] toData: " .. json.encode(element:toData()))
      result[name] = element:toData()
      --end
    end
    return result
  end
_M.case = case

-- case is a type where one or more of the defined choices can be used
local choice = inheritsFrom(BaseType)
choice_mt = { __index = choice }
  function choice:create(mandatory)
    local new_inst = BaseType:create("choice", mandatory)
    setmetatable(new_inst, choice_mt)
    new_inst.choices = {}
    -- value is a table of entries, each of which should conform to
    -- the specification of entry_elements
    return new_inst
  end

--  function choice:setValue(value)
--    -- do we need this?
--    error("Got setValue for: " .. json.encode(value))
--  end

  function choice:add_choice(name, element_type)
    self.choices[name] = element_type
    print("[XX] ADDED choice FOR " .. name .. " size now: " .. tablelength(self.choices))
  end

  function choice:fromData(data)
    print("[XX] choice fromData() data: " .. json.encode(data))
    for data_name, data_data in pairs(data) do
      print("[XX] looking for " .. data_name)
      print("[XX] my data is: " .. json.encode(data_data))
      local found = false
      for name,element_type in pairs(self.choices) do
        print("[XX] found: " .. name)
        if name == data_name then
          element_type:fromData(data_data)
          found = true
        end
        -- todo: improve error
      end
      -- fallback (can we remove the above and only use this?
      if not found then
        print("[XX] TRYING FULL START")
        for name,element_type in pairs(self.choices) do
          print("[XX] TRYING FULL PARSE OF " .. json.encode(data))
          local status = pcall(element_type.fromData, element_type, data)
          if status then found = true end
        end
        if not found then error("Unknown choice value: " .. data_name) end
      end
    end
  end

  function choice:toData(data)
    local result = {}
    for name,element in pairs(self.choices) do
      -- TODO: do we need a hasValue() check for all types?
      --if element:getValue() ~= nil then
      local v = element:toData()
      if v ~= nil and (type(v) ~= 'table' or tablelength(v) > 0) then
        result[name] = element:toData()
      end
    end
    return result
  end
_M.choice = choice

return _M


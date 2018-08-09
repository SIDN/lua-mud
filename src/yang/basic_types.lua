
local luadate = require("date")
local url = require("socket.url")



local util = require("yang.util")

local _M = {}

local BaseType = {}
local BaseType_mt = { __index = BaseType }
  function BaseType:create(typeName, nodeName, mandatory)
    if type(nodeName) ~= 'string' then
      print("NODENAME: " .. nodeName)
      error("missing mandatory argument nodeName in yang_type:create() for " .. typeName)
    end
    local new_inst = {}
    setmetatable(new_inst, BaseType)
    new_inst.value = nil
    new_inst.typeName = typeName
    new_inst.nodeName = nodeName
    new_inst.parent = nil
    if mandatory ~= nil then
      new_inst.mandatory = mandatory
    else
      new_inst.mandatory = true
    end
    return new_inst
  end

  function BaseType:getName()
    return self.nodeName
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

  -- Returns the first node that matches the given xpath-style path
  -- foo/bar[1]/value
  -- returns nil+error if the path cannot be found
  function BaseType:getNode(path)
    error("Cannot use getNode on a basic type")
  end

  -- Returns all the child nodes as a list; for simple types,
  -- this returns a list with the node itself as its only content
  function BaseType:getAll()
    local result = {}
    table.insert(result, self)
    return result
  end

  function BaseType:getParent()
    return self.parent
  end

  function BaseType:setParent(node)
    self.parent = node
  end

  function BaseType:getPath()
    -- TODO: make a specific one for list, it needs the index
    if self:getParent() ~= nil then
      return self:getParent():getPath() .. "/" .. self:getName()
    else
      return self:getName()
    end
  end
-- class BaseType not exported
_M.BaseType = BaseType

local uint8 = util.subClass(BaseType)
uint8_mt = { __index = uint8 }
  function uint8:create(nodeName, mandatory)
    local new_inst = BaseType:create("uint8", nodeName, mandatory)
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

local uint16 = util.subClass(BaseType)
uint16_mt = { __index = uint16 }
  function uint16:create(nodeName, mandatory)
    local new_inst = BaseType:create("uint16", nodeName, mandatory)
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

local uint32 = util.subClass(BaseType)
uint32_mt = { __index = uint32 }
  function uint32:create(nodeName, mandatory)
    local new_inst = BaseType:create("uint32", nodeName, mandatory)
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


local boolean = util.subClass(BaseType)
boolean_mt = { __index = boolean }
  function boolean:create(nodeName, mandatory)
    local new_inst = BaseType:create("boolean", nodeName, mandatory)
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

local inet_uri = util.subClass(BaseType)
inet_uri_mt = { __index = inet_uri }
  function inet_uri:create(nodeName, mandatory)
    local new_inst = BaseType:create("inet:uri", nodeName, mandatory)
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

local date_and_time = util.subClass(BaseType)
date_and_time_mt = { __index = date_and_time }
  function date_and_time:create(nodeName, mandatory)
    local new_inst = BaseType:create("yang:date-and-time", nodeName, mandatory)
    setmetatable(new_inst, date_and_time_mt)
    return new_inst
  end

  function date_and_time:setValue(value)
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
_M.date_and_time = date_and_time

local mac_address = util.subClass(BaseType)
mac_address_mt = { __index = mac_address }
  function mac_address:create(nodeName, mandatory)
    local new_inst = BaseType:create("inet:uri", nodeName, mandatory)
    setmetatable(new_inst, mac_address_mt)
    return new_inst
  end

  function mac_address:setValue(value)
    if type(value) == 'string' then
      if not string.match(value, "^%x%x:%x%x:%x%x:%x%x:%x%x:%x%x$") then
        error("value for " .. self:getType() .. ".setValue() is not a valid MAC address: " .. value)
      end
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.mac_address = mac_address

local eth_ethertype = util.subClass(BaseType)
eth_ethertype_mt = { __index = eth_ethertype }
  function eth_ethertype:create(nodeName, mandatory)
    local new_inst = BaseType:create("inet:uri", nodeName, mandatory)
    setmetatable(new_inst, eth_ethertype_mt)
    return new_inst
  end

  function eth_ethertype:setValue(value)
    error("NOTIMPL: eth:ethertype not implemented yet")
  end
_M.eth_ethertype = eth_ethertype

local inet_dscp = util.subClass(BaseType)
inet_dscp_mt = { __index = inet_dscp }
  function inet_dscp:create(nodeName, mandatory)
    local new_inst = BaseType:create("inet:uri", nodeName, mandatory)
    setmetatable(new_inst, inet_dscp_mt)
    return new_inst
  end

  function inet_dscp:setValue(value)
    error("NOTIMPL: inet:dscp not implemented yet")
  end
_M.inet_dscp = inet_dscp

local bits = util.subClass(BaseType)
bits_mt = { __index = bits }
  function bits:create(nodeName, mandatory)
    local new_inst = BaseType:create("inet:uri", nodeName, mandatory)
    setmetatable(new_inst, bits_mt)
    return new_inst
  end

  function bits:setValue(value)
    error("NOTIMPL: bits not implemented yet")
  end
_M.bits = bits


local string = util.subClass(BaseType)
string_mt = { __index = string }
  function string:create(nodeName, mandatory)
    local new_inst = BaseType:create("string", nodeName, mandatory)
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

local notimplemented = util.subClass(BaseType)
notimplemented_mt = { __index = notimplemented }
  function notimplemented:create(nodeName, mandatory)
    local new_inst = BaseType:create("notimplemented", nodeName, mandatory)
    setmetatable(new_inst, notimplemented_mt)
    return new_inst
  end

  function notimplemented:setValue(value)
    error("Not implemented")
  end
_M.notimplemented = notimplemented

return _M

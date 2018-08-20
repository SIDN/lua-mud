local util = require("yang.util")
local basic_types = require("yang.basic_types")

-- Types based on other types
--
-- Note: the complex_types subclass is provisionary; we should probably have namespaced
-- complex types, possibly directly derived from yang files

local _M = {}

-- TODO
local acl_type = util.subClass("acl_type", basic_types.YangNode)
acl_type_mt = { __index = acl_type }
  function acl_type:create(nodeName, mandatory)
    local new_inst = basic_types.YangNode:create("acl-type", nodeName, mandatory)
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

function splitfoo(value)
  return 
end

-- based on https://tools.ietf.org/html/rfc6021
local inet_ipv4_prefix = util.subClass("inet:ipv4-prefix", basic_types.string)
inet_ipv4_prefix_mt = { __index = inet_ipv4_prefix }
  function inet_ipv4_prefix:create(nodeName, mandatory)
    local new_inst = basic_types.YangNode:create("inet:ipv4-prefix", nodeName, mandatory)
    setmetatable(new_inst, inet_ipv4_prefix_mt)
    return new_inst
  end

  function inet_ipv4_prefix:setValue(value)
    if type(value) == 'string' then
      local m = {}
      m = {string.match(value, "^([0-9]+).([0-9]+).([0-9]+).([0-9]+)/([0-9]+)$")}
      if #m ~= 5 then
        error("value for " .. self:getType() .. ".setValue() is not a valid IPv4 prefix: " .. #m)
      end
      for i,n in pairs(m) do
        v = tonumber(n)
        if i < 5 then
          if v == nil or v < 0 or v > 255 then error("IPv4 value out of range: " .. value) end
        else
          if v == nil or v < 0 or v > 32 then error("IPv4 bitmask out of range: " .. value) end
        end
      end
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.inet_ipv4_prefix = inet_ipv4_prefix

local inet_ipv6_prefix = util.subClass("inet:ipv6-prefix", basic_types.string)
inet_ipv6_prefix_mt = { __index = inet_ipv6_prefix }
  function inet_ipv6_prefix:create(nodeName, mandatory)
    local new_inst = basic_types.YangNode:create("inet:ipv6-prefix", nodeName, mandatory)
    setmetatable(new_inst, inet_ipv6_prefix_mt)
    return new_inst
  end

  function inet_ipv6_prefix:setValue(value)
    if type(value) == 'string' then
      -- IPv6 addresses are too complex for a basic matcher, and we don't want to pull in a full RE parser.
      -- So we use a bit of custom code

      -- split up in address and bitmast
      local parts = util.str_split(value, "/")
      if #parts ~= 2 then
        error("value for " .. self:getType() .. ".setValue() is not a valid ipv6 prefix (no bitmask part): " .. value)
      else
        if tonumber(parts[2]) == nil then
          error("value for " .. self:getType() .. ".setValue() is not a valid ipv6 prefix (bitmask not a number): " .. value)
        end
        if tonumber(parts[2]) < 0 or tonumber(parts[2]) > 128 then
          error("value for " .. self:getType() .. ".setValue() is not a valid ipv6 prefix (bitmask out of range): " .. value)
        end
        local addr_parts = util.str_split(parts[1], ":")
        if #addr_parts > 8 then
          error("value for " .. self:getType() .. ".setValue() is not a valid ipv6 prefix (IP address has too many parts): " .. value)
        end
        local double_count = table.getn(util.str_split(parts[1], "::")) - 1
        for i,n in pairs(addr_parts) do
          if #n > 4 then error("too large") end
          if not n:match("^[a-fA-F0-9]*$") then error("non-hex") end
        end
        if double_count > 1 then
          error("value for " .. self:getType() .. ".setValue() is not a valid ipv6 prefix (two or more ::): " .. value)
        end
        if #addr_parts < 8 and double_count == 0 then
          error("value for " .. self:getType() .. ".setValue() is not a valid ipv6 prefix (IP address has too few parts): " .. value)
        end
      end
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.inet_ipv6_prefix = inet_ipv6_prefix

return _M

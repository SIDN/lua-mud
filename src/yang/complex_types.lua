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

return _M

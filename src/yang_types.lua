
local _M = {}
-- helper classes for the basic types used in YANG


local Int8Type = {}
Int8Type_mt = { __index = Int8Type }
  function Int8Type:create()
    local new_inst = {}
    setmetatable(new_inst, Int8Type_mt)
    new_inst.value = nil
    return new_inst
  end

  function Int8Type:getType()
    return "uint8"
  end

  function Int8Type:setValue(value)
    if type(value) == 'number' then
      if value < 0 or value > 255 then
        error("value for " .. set.getType() .. " out of range: " .. value)
      else
        self.value = value
      end
    else
      error("type error: " .. self.getType() .. ".setValue() with type " .. type(value) .. " instead of number")
    end
  end

  function Int8Type:getValue(value)
    return self.value
  end
_M.Int8Type = Int8Type

local BooleanType = {}
BooleanType_mt = { __index = BooleanType }
  function BooleanType:create()
    local new_inst = {}
    setmetatable(new_inst, BooleanType_mt)
    new_inst.value = nil
    return new_inst
  end

  function BooleanType:getType()
    return "boolean"
  end

  function BooleanType:setValue(value)
    if type(value) == 'boolean' then
      self.value = value
    else
      error("type error: " .. self.getType() .. ".setValue() with type " .. type(value) .. " instead of boolean")
    end
  end

  function BooleanType:getValue(value)
    return self.value
  end
_M.BooleanType = BooleanType




return _M

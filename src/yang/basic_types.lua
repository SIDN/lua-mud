
local luadate = require("date")
local url = require("socket.url")

local json = require("cjson")

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

-- a container is the general-purpose holder of data that is not of any specific type
-- essentially, it's the 'main' holder of definitions and data
local container = util.subClass(_M.BaseType)
container_mt = { __index = container }
  function container:create(nodeName, mandatory)
    local new_inst = _M.BaseType:create("container", nodeName, mandatory)
    setmetatable(new_inst, container_mt)
    new_inst.yang_nodes = {}
    -- a container's value is contained in its yang nodes
    new_inst.value = nil
    return new_inst
  end

  function container:add_node(node_type_instance)
    if node_type_instance == nil then error("container:add_node() called with nil node_type_instance") end
    self.yang_nodes[node_type_instance:getName()] = node_type_instance
  end

  function container:fromData(json_data, check_all_data_used)
    for node_name, node in pairs(self.yang_nodes) do
      if json_data[node_name] ~= nil then
        node:fromData(json_data[node_name])
        node:setParent(self)
        json_data[node_name] = nil
      elseif node:isMandatory() then
        --error('mandatory node ' .. node_name .. ' not found in: ' .. json.encode(json_data[node_name]))
        error('mandatory node ' .. node_name .. ' not found in: ' .. json.encode(json_data))
      --else
      --  print("[XX] node with name " .. node_name .. " has no value but not mandatory: " .. json.encode(node:isMandatory()))
      end
    end

    if json.encode(json_data) ~= "{}" then
      error("Unhandled data: " .. json.encode(json_data))
    end
  end

  function container:hasValue()
    for i,node in pairs(self.yang_nodes) do
      if node:hasValue() then return true end
    end
    return false
  end

  function container:print()
    print(self:getValueAsString())
  end

  function container:getValueAsString()
    local result = "{ "
    for node_name, node in pairs(self.yang_nodes) do
      if node:hasValue() then
        result = result .. "  " .. node_name .. ": " .. node:getValueAsString() .. "\n"
      else
        result = result .. "  " .. node_name .. ": <not set>\n"
      end
    end
    result = result .. "}\n"
    return result
  end

  function container:toData()
    local result = {}
    for name,value in pairs(self.yang_nodes) do
      local v = value:toData()
      -- exclude empty nodes
      --print("[XX] CONTAINER TODATA: " .. json.encode(v))
      if v ~= nil and (type(v) ~= 'table' or tablelength(v) > 0) then
          --print("[XX] ADDING TO CONTAINER: " .. name .. " = " .. json.encode(v))
          --if json.encode(v) == "{}" then
          --  print("[XX][XX]")
          --  print(v~=nil)
          --  print(type(v) ~= 'table')
          --  print("[XX][XX]")
          --  error("bad, empty data should not be here " .. json.encode(tablelength(v)))
          --end
          result[name] = v
      end
      --  value:toData()
      --end
      --if tablelength(v) > 0 then result[name] = value:toData() end
    end
    return result
  end

  function container:getNodeNames()
    local result = {}
    for n,_ in pairs(self.yang_nodes) do
      table.insert(result, n)
    end
    return result
  end

  function container:getNode(path, given_list_index)
    -- get and remove the first section of the path
    --local part, rest = path.
    -- validate it
    local first, rest = util.str_split_one(path, "/")
    local list_name, list_index = get_path_list_index(first)
    if list_name ~= nil then
      first = list_name
    end

    local name_to_find, rest = util.str_split_one(path, "/")
    if name_to_find == nil then
      name_to_find = rest
      rest = nil
    end
    local list_index = nil
    local list_name, list_index = get_path_list_index(name_to_find)
    if list_name ~= nil then
      name_to_find = list_name
    end

    if self.yang_nodes[name_to_find] ~= nil then
      if given_list_index ~= nil then
        error("list index specified in path on non-list element " .. self:getType() .. " (" .. path .. ")")
      end
      if self.yang_nodes[name_to_find] == nil then error("node " .. name_to_find .. " not found in " .. self:getType()) end
      if rest == nil then
        return self.yang_nodes[name_to_find]
      else
        return self.yang_nodes[name_to_find]:getNode(rest, list_index)
      end
    end
    error("node " .. name_to_find .. " not found in " .. self:getType() .. " subnodes: [ " .. util.str_join(", ", self:getNodeNames()) .. " ]")
  end

  function container:getAll()
    local result = {}
    table.insert(result, self)
    for i,n in pairs(self.yang_nodes) do
      util.table_extend(result, n:getAll())
    end
    return result
  end

  function container:hasNode(node_name)
    return self.yang_nodes[node_name] ~= nil
  end
_M.container = container

-- we implement lists by making them lists of containers, with
-- an interface that skips the container part (mostly)
local list = util.subClass(_M.BaseType)
list_mt = { __index = list }
  function list:create(nodeName)
    local new_inst = _M.BaseType:create("list", nodeName)
    setmetatable(new_inst, list_mt)
    new_inst.entry_nodes = {}
    -- value is a table of entries, each of which should conform to
    -- the specification of entry_nodes
    new_inst.value = {}
    return new_inst
  end

  function list:set_entry_node(node_type_instance)
    self.entry_nodes[node_type_instance:getName()] = node_type_instance
  end

  function list:add_node()
    local new_node = _M.container:create('list_entry')
    -- TODO: should this be a deep copy?
    new_node.yang_nodes = util.deepcopy(self.entry_nodes)
    --new_node.value = nil
    table.insert(self.value, new_node)

    -- update the childs getPath so it adds the list index
    function new_node:getPath()
      return self:getParent():getPath() .. "[" .. util.get_index_of(self:getParent():getValue(), self) .. "]"
    end
    return new_node
  end
  -- TODO: should we error on attempts to use getValue and setValue?

  function list:hasValue()
    return table.getn(self.value) > 0
  end

  function list:fromData(data)
    -- TODO: should we empty our local data to be sure at this point?
    for i,data_el in pairs(data) do
      local new_el = self:add_node()
      new_el:fromData(data_el)
      new_el:setParent(self)
    end
  end

  function list:getValueAsString()
    local result = " <LIST> [\n"
    for i,v in pairs(self.value) do
      for name,ye in pairs(v.yang_nodes) do
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

  function list:getNode(path, given_list_index)
    if given_list_index ~= nil then
      if self.value[given_list_index] == nil then error("Element " .. given_list_index .. " not found in " .. self.getType()) end
      if path ~= nil then
        return self.value[given_list_index]:getNode(path)
      else
        return self.value[given_list_index]
      end
    else
      local list_name, list_index = get_path_list_index(path)
      if list_name == nil then
        error("getNode() on list must specify list index (" .. path .. ")")
      end
    end
  end

  function list:getAll()
    local result = {}
    table.insert(result, self)
    for i,n in pairs(self.value) do
      util.table_extend(result, n:getAll())
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

-- TODO: can we derive from the definition whether we need to 'remove' the intermediate step?
-- choice is a type where one or more of the defined choices can be used
local choice = util.subClass(_M.BaseType)
choice_mt = { __index = choice }
  function choice:create(nodeName, mandatory, singlechoice)
    local new_inst = _M.BaseType:create("choice", nodeName, mandatory)
    setmetatable(new_inst, choice_mt)
    new_inst.choices = {}
    new_inst.singleChoice = singlechoice
    -- value is a table of entries, each of which should conform to
    -- the specification of entry_nodes
    return new_inst
  end

--  function choice:setValue(value)
--    -- do we need this?
--    error("Got setValue for: " .. json.encode(value))
--  end

  function choice:add_choice(name, node_type)
    self.choices[name] = node_type
  end

  function choice:fromData(data)
    for data_name, data_data in pairs(data) do
      local found = false
      for name,node_type in pairs(self.choices) do
        if name == data_name then
          node_type:fromData(data_data)
          found = true
        end
        -- todo: improve error
      end
      -- fallback (can we remove the above and only use this?
      if not found then
        for name,node_type in pairs(self.choices) do
          local status = pcall(node_type.fromData, node_type, data)
          if status then found = true end
        end
        if not found then error("Unknown choice value: " .. data_name) end
      end
    end
  end

  function choice:toData(data)
    local result = {}
    for name,node in pairs(self.choices) do
      -- TODO: do we need a hasValue() check for all types?
      --if node:getValue() ~= nil then
      local v = node:toData()
      if v ~= nil and (type(v) ~= 'table' or tablelength(v) > 0) then
        --print("[XX] CHOICE TODATA: " .. json.encode(node:toData()))
        result[name] = node:toData()
      end
      -- TODO this seems wrong
      if self.singleChoice then
        for n,v in pairs(result) do
          return v
        end
      end
      --print("[XX] RETURNING CHOICE: " .. json.encode(result))
      --print("[XX] CHOICE RESULT SIZE: " .. json.encode(tablelength(result)))
    end
    return result
  end

  function choice:hasValue()
    for name,node in pairs(self.choices) do
      if node:hasValue() then return true end
    end
    return false
  end

  -- returns the first non-empty choice
  function choice:getChoice()
    for name,node in pairs(self.choices) do
      if node:hasValue() then return node end
    end
    error('no choice set')
  end


  -- return all the choice nodes that were set
  function choice:getChoices()
    local result = {}
    for name,node in pairs(self.choices) do
      -- TODO: yeah we really need a hasValue() check
      local v = node:toData()
      if v ~= nil and (type(v) ~= 'table' or tablelength(v) > 0) then
        --print("[XX] CHOICE TODATA: " .. json.encode(node:toData()))
        table.insert(result, node)
      end
    end
    return result
  end
_M.choice = choice


return _M

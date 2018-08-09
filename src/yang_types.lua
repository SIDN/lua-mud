local json = require("cjson")

local util = require("yang.util")
local basic_types = require("yang.basic_types")

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
-- should we include the name in instances of the nodes? does that make sense?
-- does that make the named-choice-items issue any easier, or harder?

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


local acl_type = util.subClass(basic_types.BaseType)
acl_type_mt = { __index = acl_type }
  function acl_type:create(nodeName, mandatory)
    local new_inst = basic_types.BaseType:create("acl-type", nodeName, mandatory)
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
local container = util.subClass(basic_types.BaseType)
container_mt = { __index = container }
  function container:create(nodeName, mandatory)
    local new_inst = basic_types.BaseType:create("container", nodeName, mandatory)
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

function get_index_of(list, element)
  for i,v in pairs(list) do
    if v == element then
      print("[XX] yooy: " .. i)
      return i
    end
  end
  error('element not found in list')
end

-- we implement lists by making them lists of containers, with
-- an interface that skips the container part (mostly)
local list = util.subClass(basic_types.BaseType)
list_mt = { __index = list }
  function list:create(nodeName)
    local new_inst = basic_types.BaseType:create("list", nodeName)
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
    local new_node = container:create('list_entry')
    -- TODO: should this be a deep copy?
    new_node.yang_nodes = util.deepcopy(self.entry_nodes)
    --new_node.value = nil
    table.insert(self.value, new_node)

    -- update the childs getPath so it adds the list index
    function new_node:getPath()
      return self:getParent():getPath() .. "[" .. get_index_of(self:getParent():getValue(), self) .. "]"
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
local choice = util.subClass(basic_types.BaseType)
choice_mt = { __index = choice }
  function choice:create(nodeName, mandatory, singlechoice)
    local new_inst = basic_types.BaseType:create("choice", nodeName, mandatory)
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


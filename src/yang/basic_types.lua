
local luadate = require("date")
local url = require("socket.url")

local json = require("cjson")

local util = require("yang.util")

local _M = {}

local YangNode = util.subClass("YangNode", nil)
local YangNode_mt = { __index = YangNode }
  function YangNode:create(typeName, nodeName, mandatory)
    local new_inst = {}
    setmetatable(new_inst, YangNode)
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

  function YangNode:getName()
    return self.nodeName
  end

  function YangNode:getType()
    return self.typeName
  end

  function YangNode:getValue()
    return self.value
  end

  function YangNode:hasValue(value)
    return self.value ~= nil
  end

  function YangNode:clearData()
    self.value = nil
  end

  function YangNode:setValue(value)
    error("setValue needs to be implemented in subclass")
  end

  function YangNode:validate()
    error("validate needs to be implemented in subclass")
  end

  function YangNode:isMandatory()
    return self.mandatory
  end

  -- tries to set data. returns true if success, fail if not
  function YangNode:fromData_noerror(data)
    print("[XX] [BASETYPE] fromData_noerror called on " ..self:getName().. " with data " .. json.encode(data))
    r,err = pcall(self.setValue, self, data)
    print("[XX] [BASETYPE] returning fromData_noerror " .. self:getName() .. " with value: " .. tostring(r))
    if r then print("[XX] [BASETYPE] data: " .. json.encode(self:toData())) end
    return r
  end

  -- returns the current value as native data; for simple types, this
  -- is just the value itself
  function YangNode:toData()
    return self.value
  end

  -- Returns the first node that matches the given xpath-style path
  -- foo/bar[1]/value
  -- returns nil+error if the path cannot be found
  function YangNode:getNode(path)
    error("Cannot use getNode on a basic type")
  end

  -- Returns all the child nodes as a list; for simple types,
  -- this returns a list with the node itself as its only content
  function YangNode:getAll()
    local result = {}
    table.insert(result, self)
    return result
  end

  function YangNode:getParent()
    return self.parent
  end

  function YangNode:getRootNode()
    local curNode = self
    print("[XX] LOOKING FOR ROOT NODE OF " .. curNode:getName() .. " (" .. tostring(curNode))
    while curNode:getParent() ~= nil do
      print("[XX] LOOKING FOR ROOT NODE2 OF " .. curNode:getName() .. " (" .. tostring(curNode))
      curNode = curNode:getParent()
      print("[XX] LOOKING FOR ROOT NODE2.2 OF " .. curNode:getName() .. " (" .. tostring(curNode))
      if (curNode:getParent() == nil) then
        print("[XX] LOOKING BUT " .. curNode:getName() .. " has no parent" .. " (" .. tostring(curNode))
      end
    end
      print("[XX] LOOKING FOR ROOT NODE3 OF " .. curNode:getName() .. " (" .. tostring(curNode))
    return curNode
  end

  function YangNode:setParent(parent, recurse)
    print("[XX] SETPARENT OF " .. self:getName() .. " TO " .. parent:getName())
    self.parent = parent
  end

  -- requester may be zero; it is passed to the getPath of the
  -- parent; in some cases the result may differ depending on who's asking
  -- (like, say, list indices)
  function YangNode:getPath(requester)
    print("[XX] GETPATH OF " .. self:getType() .. " " .. self:getName() .. " with data " .. json.encode(self:toData()))
    if requester ~= nil then
      print("[XX] GETPATH REQUESTED BY " .. requester:getName() .. " which has data " .. json.encode(requester:toData()))
    end
    if self.parent ~= nil then
      return self.parent:getPath(self) .. "/" .. self:getName()
    else
      return self:getName()
    end
  end
_M.YangNode = YangNode

local uint8 = util.subClass("uint8", YangNode)
uint8_mt = { __index = uint8 }
  function uint8:create(nodeName, mandatory)
    local new_inst = YangNode:create("uint8", nodeName, mandatory)
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

local uint16 = util.subClass("uint16", YangNode)
uint16_mt = { __index = uint16 }
  function uint16:create(nodeName, mandatory)
    local new_inst = YangNode:create("uint16", nodeName, mandatory)
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

local uint32 = util.subClass("uint32", YangNode)
uint32_mt = { __index = uint32 }
  function uint32:create(nodeName, mandatory)
    local new_inst = YangNode:create("uint32", nodeName, mandatory)
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


local boolean = util.subClass("boolean", YangNode)
boolean_mt = { __index = boolean }
  function boolean:create(nodeName, mandatory)
    local new_inst = YangNode:create("boolean", nodeName, mandatory)
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

local inet_uri = util.subClass("inet_uri", YangNode)
inet_uri_mt = { __index = inet_uri }
  function inet_uri:create(nodeName, mandatory)
    local new_inst = YangNode:create("inet_uri", nodeName, mandatory)
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

local date_and_time = util.subClass("date_and_time", YangNode)
date_and_time_mt = { __index = date_and_time }
  function date_and_time:create(nodeName, mandatory)
    local new_inst = YangNode:create("yang:date-and-time", nodeName, mandatory)
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

local mac_address = util.subClass("mac_address", YangNode)
mac_address_mt = { __index = mac_address }
  function mac_address:create(nodeName, mandatory)
    local new_inst = YangNode:create("mac_address", nodeName, mandatory)
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

local eth_ethertype = util.subClass("eth_ethertype", YangNode)
eth_ethertype_mt = { __index = eth_ethertype }
  function eth_ethertype:create(nodeName, mandatory)
    local new_inst = YangNode:create("eth_ethertype", nodeName, mandatory)
    setmetatable(new_inst, eth_ethertype_mt)
    return new_inst
  end

  function eth_ethertype:setValue(value)
    error("NOTIMPL: eth:ethertype not implemented yet")
  end
_M.eth_ethertype = eth_ethertype

local inet_dscp = util.subClass("inet_dscp", YangNode)
inet_dscp_mt = { __index = inet_dscp }
  function inet_dscp:create(nodeName, mandatory)
    local new_inst = YangNode:create("inet_dscp", nodeName, mandatory)
    setmetatable(new_inst, inet_dscp_mt)
    return new_inst
  end

  function inet_dscp:setValue(value)
    error("NOTIMPL: inet:dscp not implemented yet")
  end
_M.inet_dscp = inet_dscp

local bits = util.subClass("bits", YangNode)
bits_mt = { __index = bits }
  function bits:create(nodeName, mandatory)
    local new_inst = YangNode:create("bits", nodeName, mandatory)
    setmetatable(new_inst, bits_mt)
    return new_inst
  end

  function bits:setValue(value)
    error("NOTIMPL: bits not implemented yet")
  end
_M.bits = bits


local string = util.subClass("string", YangNode)
string_mt = { __index = string }
  function string:create(nodeName, mandatory)
    local new_inst = YangNode:create("string", nodeName, mandatory)
    setmetatable(new_inst, string_mt)
    return new_inst
  end

  function string:setValue(value)
    if type(value) == 'string' then
      self.value = value
    else
      error("type error: " .. self:getType() .. ".setValue() with type " .. type(value) .. " instead of string")
    end
  end
_M.string = string

local notimplemented = util.subClass("notimplemented", YangNode)
notimplemented_mt = { __index = notimplemented }
  function notimplemented:create(nodeName, mandatory)
    local new_inst = YangNode:create("notimplemented", nodeName, mandatory)
    setmetatable(new_inst, notimplemented_mt)
    return new_inst
  end

  function notimplemented:setValue(value)
    error("Not implemented")
  end
_M.notimplemented = notimplemented

-- a container is the general-purpose holder of data that is not of any specific type
-- essentially, it's the 'main' holder of definitions and data
local container = util.subClass("container", _M.YangNode)
container_mt = { __index = container }
  function container:create(nodeName, mandatory)
    local new_inst = _M.YangNode:create("container", nodeName, mandatory)
    setmetatable(new_inst, container_mt)
    new_inst.yang_nodes = {}
    -- a container's value is contained in its yang nodes
    new_inst.value = nil
    return new_inst
  end

  function container:add_node(node_type_instance)
    if node_type_instance == nil then error("container:add_node() called with nil node_type_instance") end
    self.yang_nodes[node_type_instance:getName()] = node_type_instance
    print("[XX] [CONTAINER] [SETPARENT] of " ..node_type_instance:getName() .. " TO " .. self:getName())
    node_type_instance:setParent(self)
  end

  function container:setParent(parent, recurse)
    self.parent = parent
    if recurse then
      for i,n in pairs(self.yang_nodes) do n:setParent(self, recurse) end
    end
  end

  function container:fromData_noerror(data)
    if type(data) ~= 'table' then
      return false
    end
    local any_match = false
    for node_name, node in pairs(self.yang_nodes) do
      -- special case for choices
      if node:isa(_M.choice) then
        for cname,cnode in pairs(data) do
          if node:hasCase(cname) and node:fromData_noerror(cnode, cname) then
            any_match = true
            break
          end
        end
      elseif data[node_name] ~= nil then
        if node:fromData_noerror(data[node_name]) then
          any_match = true
        end
      end
    end
    if any_match and self:getName() == "matches" then
      print("[XX] NOT GETPATH BUT DATA OF " .. tostring(self) .. " NOW " .. json.encode(self:toData()))
      print("[XX] NOT GETPATH BUT THAT MAKES MY PARENT HAVE " .. json.encode(self:getParent():toData()))
      if self:getParent():getParent() ~= nil then
        print("[XX] GETPATH GRANDPARENT IS OF TYPE " .. self:getParent():getParent():getType())
      end
      print("[XX] NOT GETPATH BUT THAT MAKES MY PARENT HAVE " .. json.encode(self:getParent():toData()))
    end
    return any_match
  end

  function container:clearData()
    for node_name, node in pairs(self.yang_nodes) do
      node:clearData()
    end
  end

  function container:hasValue()
    for i,node in pairs(self.yang_nodes) do
      if node:hasValue() then
        print("[XX] [CONTAINER] hasValue() called on " .. self:getName() .. ": true")
        return true
      end
    end
    print("[XX] [CONTAINER] hasValue() called on " .. self:getName() .. ": false")
    return false
  end

  function container:toData()
    local result = {}
    for name,value in pairs(self.yang_nodes) do
      local v
      -- if the child element is a choice, the name is not the name of the element, but of its
      -- active case
      local actual_name = name
      if value:isa(_M.choice) then
        if value:getActiveCase() ~= nil then
          actual_name = value:getActiveCase():getName()
          v = value:toData()
        else
          v = nil
        end
      else
        v = value:toData()
      end
      -- exclude empty nodes
      if v ~= nil and (type(v) ~= 'table' or tablelength(v) > 0) then
          result[actual_name] = v
      end
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
      if n:hasValue() then
        util.table_extend(result, n:getAll())
      end
    end
    return result
  end

  function container:hasNode(node_name)
    return self.yang_nodes[node_name] ~= nil
  end
_M.container = container

-- we implement lists by making them lists of containers, with
-- an interface that skips the container part (mostly)
local list = util.subClass("list", _M.YangNode)
list_mt = { __index = list }
  function list:create(nodeName)
    local new_inst = _M.YangNode:create("list", nodeName)
    setmetatable(new_inst, list_mt)
    new_inst.entry_nodes = {}
    -- value is a table of entries, each of which should conform to
    -- the specification of entry_nodes
    new_inst.value = {}
    return new_inst
  end

  -- Add a node definition for the list entries
  -- Note: this is NOT to add list elements, use create_list_element()
  -- for that. This is to define what those elements should look like
  function list:add_list_node(node_type_instance)
    self.entry_nodes[node_type_instance:getName()] = node_type_instance
    node_type_instance:setParent(self)
    print("[XX] MAYBE RELEVANT TOO FOR GETPATH BUT I JUST SET A PARENT TO " .. tostring(node_type_instance))
  end

  function list:setParent(parent, recurse)
    self.parent = parent
    if recurse then
      for i,n in pairs(self.entry_nodes) do n:setParent(self, recurse) end
      for i,n in pairs(self.value) do n:setParent(self, recurse) end
    end
  end

  -- Create a new entry in the list, based on the specification
  -- of earlier add_list_node calls, without any value
  -- the new entry is returned so the caller can add values
  -- TODO: add optional data argument to immediately fill it?
  function list:create_list_element()
    local new_node = _M.container:create('list_entry')
    -- TODO: should this be a deep copy?
    new_node.yang_nodes = util.deepcopy(self.entry_nodes)
    --new_node.value = nil
    table.insert(self.value, new_node)
    new_node:setParent(self, true)
    for i,n in pairs(new_node.yang_nodes) do
      n:setParent(new_node)
    end
    return new_node
  end
  -- TODO: should we error on attempts to use getValue and setValue?

  -- Returns true if the list contains one or more elements
  function list:hasValue()
    return table.getn(self.value) > 0
  end

  function list:fromData_noerror(data)
    print("[XX] [LIST] fromData_noerror called on " ..self:getName().. " with data " .. json.encode(data))
    local any_match = false
    for i,data_el in pairs(data) do
      local new_el = self:create_list_element()
      if new_el:fromData_noerror(data_el) then
        any_match = true
        print("[XX] MAYBE RELEVANT FOR GETPATH BUT NEW ENTRY IS " .. tostring(new_el))
      end
    end
    print("[XX] [LIST] returning fromData_noerror " .. self:getName() .. " with value: " .. tostring(any_match))
    if any_match then
      print("[XX] [LIST] data: " .. json.encode(self:toData()))
    end
    return any_match
  end

  function list:clearData()
    self.entry_nodes = {}
  end

  -- Returns the list elements as raw data
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

  -- Returns all the elements in the list (as container YangNodes)
  function list:getAll()
    local result = {}
    table.insert(result, self)
    for i,n in pairs(self.value) do
      util.table_extend(result, n:getAll())
    end
    return result
  end

  function list:getPath(requester)
    print("[XX] GETPATH OF LIST " .. self:getName() .. " with data: " .. json.encode(self:toData()))
    if requester ~= nil then
      print("[XX] GETPATH REQUESTED BY " .. requester:getName() .. " which has data " .. json.encode(requester:toData()))
    end
    local index_str = ""
    local parent_str = ""
    if self.parent ~= nil then
      parent_str = self.parent:getPath(self) .. "/"
    end
    if requester ~= nil then
      index_str = "[?]"
      for i,n in pairs(self.value) do
        if n == requester then
          index_str = "[" .. i .. "]"
        end
      end
    end
    return parent_str .. self:getName() .. index_str
  end
_M.list = list

-- TODO: remove
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local choice = util.subClass("choice", _M.YangNode)
choice_mt = { __index = choice }

  -- note that nodename is only used in the schema, not the data
  function choice:create(nodeName, mandatory)
    local new_inst = _M.YangNode:create("choice", nodeName, mandatory)
    setmetatable(new_inst, choice_mt)
    new_inst.cases = {}
    return new_inst
  end

  -- cases can be of any type
  -- TODO: how to handle block of multiple statements in one case? Does this happen?
  function choice:add_case(caseName, caseNode)
    self.cases[caseName] = caseNode
    caseNode:setParent(self)
  end

  function choice:setParent(parent, recurse)
    self.parent = parent
    if recurse then
      for i,n in pairs(self.cases) do n:setParent(self, recurse) end
    end
  end

  function choice:getCaseCount()
    local result = 0
    for _,__ in pairs(self.cases) do
      result = result + 1
    end
    return result
  end

  function choice:getAll()
    local result = {}
    local active = self:getActiveCase()
    if active ~= nil then
      table.insert(result, active)
    end
    return result
  end

  function choice:getPath(requester)
    print("[XX] GETPATH OF CHOICE " .. self:getName() .. " " .. json.encode(self:toData()))
    if requester ~= nil then
      print("[XX] GETPATH REQUESTED BY " .. requester:getName() .. " which has data " .. json.encode(requester:toData()))
    end
    -- the choice itself does not show up in the data
    if self.parent ~= nil then
      print("[XX] passing GETPATH to parent " .. self.parent:getName() .. "(" ..  tostring(self.parent) .. ")")
      return self.parent:getPath(self)
    else
      return ""
    end
  end

  -- TODO remove this
  function choice:set_named(is_named)
  end

  function choice:getActiveCase()
    for i,c in pairs(self.cases) do
      if c:hasValue() then
        return c
      end
    end
  end

  function choice:clearData()
    local active_case = self:getActiveCase()
    if active_case ~= nil then
      self:getActiveCase():clearData()
    end
  end

  function choice:toData()
    local ac = self:getActiveCase()
    if ac == nil then return nil end
    return ac:toData()
  end

  -- Returns true if a value has been set
  function choice:setValue(value)
    for case_name,case in pairs(self.cases) do
      print("[XX] try choice: " .. self:getPath() .. " with data: " .. json.encode(value))
    end
    error("No valid choice found for choice " .. self:getName())
  end

  function choice:hasValue()
    for i,n in pairs(self.cases) do
      if n:hasValue() then
        print("[XX] [CHOICE] hasValue() called on " .. self:getName() .. ": true")
        return true
      end
    end
    print("[XX] [CHOICE] hasValue() called on " .. self:getName() .. ": false")
    return false
  end

  function choice:hasCase(case_name)
    print("[XX] [CHOICE] hasCase called with val " .. case_name)
    for i,n in pairs(self.cases) do
      print("[XX] [CHOICE] trying case " .. n:getName())
      if n:getName() == case_name then return true end
    end
    return false
  end

  -- if choice_name is not nil, it is checked against the cases
  -- if it is nil, any case with a matching dataset succeeds
  function choice:fromData_noerror(data, choice_name)
    print("[XX] [CHOICE] fromData_noerror called on " ..self:getName().. " with data " .. json.encode(data))
    -- can we do this better? right now we copy, and clear them, then put them back
    -- the reason for this is 1: no changes if it fails, 2. to keep track of whether one
    -- succeeded and 3. reset the other cases if one succeeds
    local cases_copy = util.deepcopy(self.cases)
    local found = false
    for n,c in pairs(cases_copy) do
      c:clearData()
      if not found then
        print("[XX] [CHOICE] trying option " .. c:getName() .. " (" .. c:getType() .. ")")
        print("[XX] [CHOICE] with data: " .. json.encode(data))
        if c:fromData_noerror(data) then
          if choice_name == nil or choice_name == c:getName() then
            found = true
            print("[XX] [CHOICE] found it in " .. c:getName() .. ": " .. json.encode(c:toData()))
          end
        end
      end
    end
    print("[XX] [CHOICE] returning fromData_noerror " .. self:getName() .. " with value: " .. tostring(found))
    if found then
      print("[XX] [CHOICE] data: " .. json.encode(self:toData()))
      self.cases = cases_copy
      for i,c in pairs(self.cases) do
        c:setParent(self)
      end
    end
    return found
  end
  --function choice:
_M.choice = choice

return _M

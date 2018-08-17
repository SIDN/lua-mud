
local json = require("json")

local _M = {}

local util = require("yang.util")
local basic_types = require("yang.basic_types")
local complex_types = require("yang.complex_types")

_M.util = util
_M.basic_types = basic_types
_M.complex_types = complex_types

--
-- General functions for Yang nodes, like node search etc
--

function _M.findNodeWithProperty(base_node, node_to_find, property_name, property_value)
    for i,potential_node in pairs(base_node:getAll()) do
        if potential_node:getName() == node_to_find then
            if potential_node:isa(_M.basic_types.container) then
                if potential_node:hasNode(property_name) then
                    local property = potential_node:getNode(property_name)
                    if property:getValue() == property_value then
                        return potential_node
                    end
                end
            elseif potential_node:isa(_M.basic_types.list) then
                for i,list_node in pairs(potential_node:getValue()) do
                    if list_node:hasNode("name") and list_node:getNode("name"):getValue() == property_value then
                        return list_node
                    end
                end
            else
                error("can only use findNodeWithProperty on list or container nodes, not " .. potential_node:getType())
            end
        end
    end
    error("node with name " .. node_to_find .. " and property " .. property_name .. " = " .. json.encode(property_value) .. " not found. Check if type and value are correct")
end

--
-- Path specification:
-- Example: /foo/bar[2]/baz
-- TODO: /foo/bar[*]/baz
-- TODO: /foo/*/baz

local function getRootNode(base_node)
  local cur_node = base_node
  while cur_node:getParent() ~= nil do
    cur_node = cur_node:getParent()
  end
  return cur_node
end
_M.getRootNode = getRootNode

-- Returns a list of nodes that match the given path
-- Returns empty list if not found
function _M.findNodes(base_node, path)
  local result_nodes = {}
  local cur_node = base_node
  print("[XX] PATH ORIG: " .. path)
  print("[XX] BASE NODE PATH: " .. base_node:getPath())
  -- First of all, check if the path starts at the root ('/') or is relative
  -- to the given node
  if util.string_starts_with(path, "/") then
    print("[XX] finding root node from: " .. base_node:getName())
    cur_node = getRootNode(base_node)
    print("[XX] root node: " .. cur_node:getPath())
    path = path:sub(2)
  end
  --print("[XX] PATH NOW: " .. path)
  --print("[XX] CUR NODE PATH:  " .. cur_node:getPath())

  --

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

  if list_index ~= nil then
    print("[XX] looking for '" .. name_to_find .. "' (list index " .. list_index ..") in " .. cur_node:getName())
  else
    print("[XX] looking for '" .. name_to_find .. "' (not a list) in " .. cur_node:getName())
  end

  if cur_node.yang_nodes ~= nil and (name_to_find == "*" or cur_node.yang_nodes[name_to_find]) ~= nil then
    local next_nodes = {}
    if name_to_find == "*" then
      -- * also means every list item if the next_node is a list
      util.table_extend(next_nodes, cur_node.yang_nodes)
    else
      local next_node = cur_node.yang_nodes[name_to_find]
      if list_index ~= nil then
        if next_node:isa(basic_types.list) then
          print("[XX] IT IS INDEED A LIST")
          if list_index < 0 then
            print("[XX] TAKE THEM ALL")
            util.table_extend(next_nodes, next_node.value)
          elseif next_node.value[list_index] ~= nil then
            table.insert(next_nodes, next_node.value[list_index])
            --next_node = next_node.value[list_index]
          else
            error("list index out of bounds")
          end
        else
          error("list index specified in path on non-list element " .. next_node:getName() .. " (" .. next_node:getType() .. ")")
          print("[XX] BUT NO LIST IS")
        end
      else
        print("[XX] ok, not a list")
        table.insert(next_nodes, next_node)
      end
    end
    --if self.yang_nodes[name_to_find] == nil then error("node " .. name_to_find .. " not found in " .. self:getType()) end
    if rest == nil then
      print("[XX] no rest, we found something. i think")
      util.table_extend(result_nodes, next_nodes)
    else
      for i,nn in pairs(next_nodes) do
        util.table_extend(result_nodes, _M.findNodes(nn, rest))
      end
    end
  end

  print("[XX] returning " .. table.getn(result_nodes) .. " nodes")
  return result_nodes
end


-- Returns the first node that matches the given path, if any
-- Returns nil if not found
function _M.findSingleNode(base_node, path)
  local nodes = _M.findNodes(base_node, path)
  if table.getn(nodes) > 0 then return nodes[1] else return nil end
end

function _M.nodeListToData(node_list)
  local result = {}
  for i,n in pairs(node_list) do
    table.insert(result, n:toData())
  end
  return result
end

return _M

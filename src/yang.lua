
local json = require("json")

local _M = {}

_M.util = require("yang.util")
_M.basic_types = require("yang.basic_types")
_M.complex_types = require("yang.complex_types")

-- Yang functions, like node search etc
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


return _M

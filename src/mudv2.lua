
-- MUD container

local json = require("cjson")
local yt = require "yang_types"

local _M = {}

-- ietf-access-control-list is a specialized type; the base of it is a container
local ietf_access_control_list = inheritsFrom(yt.container)
ietf_access_control_list_mt = { __index = ietf_access_control_list }
  function ietf_access_control_list:create(nodeName, mandatory)
    local new_inst = yt.container:create(nodeName, mandatory)
    -- additional step: add the type name
    new_inst.typeName = "acl"
    setmetatable(new_inst, ietf_access_control_list_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_access_control_list:add_definition()
    local acl_list = yt.list:create('acl')
    acl_list:set_entry_node(yt.string:create('name', true))
    acl_list:set_entry_node(yt.acl_type:create('type', false))

    local aces = yt.container:create('aces')
    local ace_list = yt.list:create('ace')
    ace_list:set_entry_node(yt.string:create('name'))
    local matches = yt.choice:create('matches')

    local matches_eth = yt.container:create('eth')
    matches_eth:add_node(yt.yang_mac_address:create('destination-mac-address'))
    matches_eth:add_node(yt.yang_mac_address:create('destination-mac-address-mask'))
    matches_eth:add_node(yt.yang_mac_address:create('source-mac-address'))
    matches_eth:add_node(yt.yang_mac_address:create('source-mac-address-mask'))
    matches_eth:add_node(yt.eth_ethertype:create('ethertype'))

    local matches_ipv4 = yt.container:create('ipv4')
    matches_ipv4:add_node(yt.inet_dscp:create('dscp', false))
    matches_ipv4:add_node(yt.uint8:create('ecn', false))
    matches_ipv4:add_node(yt.uint16:create('length', false))
    matches_ipv4:add_node(yt.uint8:create('ttl', false))
    matches_ipv4:add_node(yt.uint8:create('protocol', false))
    matches_ipv4:add_node(yt.uint8:create('ihl', false))
    matches_ipv4:add_node(yt.bits:create('flags', false))
    matches_ipv4:add_node(yt.uint16:create('offset', false))
    matches_ipv4:add_node(yt.uint16:create('identification', false))
    -- TODO: -network
    matches_ipv4:add_node(yt.string:create('ietf-acldns:dst-dnsname', false))
    matches_ipv4:add_node(yt.string:create('ietf-acldns:src-dnsname', false))

    local matches_ipv6 = yt.container:create('ipv6')
    matches_ipv6:add_node(yt.inet_dscp:create('dscp', false))
    matches_ipv6:add_node(yt.uint8:create('ecn', false))
    matches_ipv6:add_node(yt.uint16:create('length', false))
    matches_ipv6:add_node(yt.uint8:create('ttl', false))
    matches_ipv6:add_node(yt.uint8:create('protocol', false))
    matches_ipv6:add_node(yt.string:create('ietf-acldns:dst-dnsname', false))
    matches_ipv6:add_node(yt.string:create('ietf-acldns:src-dnsname', false))
    -- TODO: -network
    -- TODO: flow-label

    local matches_tcp = yt.container:create('tcp')
    matches_tcp:add_node(yt.uint32:create('sequence-number', false))
    matches_tcp:add_node(yt.uint32:create('acknowledgement-number', false))
    matches_tcp:add_node(yt.uint8:create('offset', false))
    matches_tcp:add_node(yt.uint8:create('reserved', false))

    local source_port_choice = yt.choice:create('source-port', false, true)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yt.container:create('choice-operator')
    choice_operator:add_node(yt.string:create('operator'))
    choice_operator:add_node(yt.uint16:create('port'))
    source_port_choice:add_choice('operator', choice_operator)
    matches_tcp:add_node(source_port_choice)

    local destination_port_choice = yt.choice:create('destination-port', false, true)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yt.container:create('choice-operator')
    choice_operator:add_node(yt.string:create('operator'))
    choice_operator:add_node(yt.uint16:create('port'))
    --choice_operator:makePresenceContainer()
    destination_port_choice:add_choice('operator2', choice_operator)
    matches_tcp:add_node(destination_port_choice)

    -- this is an augmentation from draft-mud
    -- TODO: type 'direction' (enum?)
    matches_tcp:add_node(yt.string:create('ietf-mud:direction-initiated', false))

    matches:add_choice('eth', matches_eth)
    matches:add_choice('ipv4', matches_ipv4)
    matches:add_choice('tcp', matches_tcp)
    matches:add_choice('ipv6', matches_ipv6)
    ace_list:set_entry_node(matches)
    aces:add_node(ace_list)

    local actions = yt.container:create('actions')
    -- todo identityref
    actions:add_node(yt.string:create('forwarding'))
    actions:add_node(yt.string:create('logging', false))

    ace_list:set_entry_node(actions)
    acl_list:set_entry_node(aces)

    -- report: discrepancy between example and definition? (or maybe just tree)
    -- TODO: look up what to do with singular/plural, maybe that is stated somewhere
    self:add_node(acl_list)
  end
-- class ietf_access_control_list

local ietf_mud_type = inheritsFrom(yt.container)
ietf_mud_type_mt = { __index = ietf_mud_type }
  function ietf_mud_type:create(nodeName, mandatory)
    local new_inst = yt.container:create(nodeName, mandatory)
    -- additional step: add the type name
    new_inst.typeName = "mud"
    setmetatable(new_inst, ietf_mud_type_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_mud_type:add_definition()
    local c = yt.container:create('mud')
    c:add_node(yt.uint8:create('mud-version', 'mud-version'))
    c:add_node(yt.inet_uri:create('mud-url', 'mud-url', true))
    c:add_node(yt.yang_date_and_time:create('last-update'))
    c:add_node(yt.inet_uri:create('mud-signature', false))
    c:add_node(yt.uint8:create('cache-validity', false))
    c:add_node(yt.boolean:create('is-supported'))
    c:add_node(yt.string:create('systeminfo', false))
    c:add_node(yt.string:create('mfg-name', false))
    c:add_node(yt.string:create('model-name', false))
    c:add_node(yt.string:create('firmware-rev', false))
    c:add_node(yt.inet_uri:create('documentation', false))
    c:add_node(yt.notimplemented:create('extensions', false))

    local from_device_policy = yt.container:create('from-device-policy')
    local access_lists = yt.container:create('access-lists')
    local access_lists_list = yt.list:create('access-list')
    -- todo: references
    access_lists_list:set_entry_node(yt.string:create('name'))
    print("[XX] ACLL NAME: " .. access_lists_list:getName())
    access_lists:add_node(access_lists_list)
    -- this seems to be a difference between the example and the definition
    from_device_policy:add_node(access_lists)
    c:add_node(from_device_policy)

    local to_device_policy = yt.container:create('to-device-policy')
    local access_lists = yt.container:create('access-lists')
    local access_lists_list = yt.list:create('access-list')
    -- todo: references
    access_lists_list:set_entry_node(yt.string:create('name'))
    access_lists:add_node(access_lists_list)
    -- this seems to be a difference between the example and the definition
    to_device_policy:add_node(access_lists)
    c:add_node(to_device_policy)

    -- it's a presence container, so we *replace* the base node list instead of adding to it
    self.yang_nodes = c.yang_nodes
  end
-- class ietf_mud_type

local function tdump (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tdump(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))
    else
      print(formatting .. v)
    end
  end
end

local function findNodesWithProperty(base_node, node_to_find, property_name, property_value)
    for i,all_node in pairs(base_node:getAll()) do
        print("[XX] TRYING NODE TYPE " .. all_node:getType() .. " FOR " .. node_to_find)
        if all_node:getType() == "container" and all_node:hasNode(node_to_find) then
            print("[XX] container with " .. node_to_find)
            local potential_node = all_node:getNode(node_to_find)
            if potential_node:hasNode(property_name) then
                local property = potential_node:getNode(property_name)
                if property:getValue() == property_value then
                    return potential_node
                end
            end
            error("node with name " .. node_to_find .. " and property " .. property_name .. " not found")
            if potential_node:getType() == "list" then
                error("foo")
            end
            for i,ace_node in pairs(ace_nodes:getValue()) do
                print("[XX] ACE_NODE TYPE: " .. ace_node:getType())
                if ace_node:hasNode("name") then
                    print(ace_node:getNode("name"):getValue())
                end
                if ace_node:hasNode("name") and ace_node:getNode("name"):getValue() == n then
                    print("[XX] WE GOT HIM")
                end
            end
        end
    end
    --error("node with name " .. node_to_find .. " and property " .. property_name .. " = " .. json.encode(property_value) .. " not found")
end

local mud = {}
mud_mt = { __index = mud }
  -- create an empty mud container
  function mud:create()
    local new_inst = {}
    setmetatable(new_inst, mud_mt)
    -- default values and types go here

    new_inst.mud = ietf_mud_type:create('mud')

    --local acl = yt.container:create()
    new_inst.acls = ietf_access_control_list:create('access-control-list')
    return new_inst
  end

  -- parse from json file
  function mud:parseFile(json_file_name)
    local file, err = io.open(json_file_name)
    if file == nil then
      error(err)
    end
    local contents = file:read( "*a" )
    local json_data, err = json.decode(contents);
    if json_data == nil then
      error(err)
    end
    io.close( file )
    if json_data['ietf-mud:mud'] == nil then
      error("Top-level node 'ietf-mud:mud' not found in " .. json_file_name)
    end
    local mud_data = json_data['ietf-mud:mud']
    self.mud:fromData(mud_data)

    if json_data['ietf-access-control-list:acls'] == nil then
      error("Top-level node 'ietf-access-control-list:acls' not found in " .. json_file_name)
    end
    local acls_data = json_data['ietf-access-control-list:acls']
    self.acls:fromData(acls_data)

    --self.acls:parseJson(json_data)
  end

  function mud:print()
    local data = {}
    data["ietf-access-control-list:acls"] = self.acls:toData()
    data["ietf-mud:mud"] = self.mud:toData()
    print(json.encode(data))
  end


  -- These are functions that might need refactoring into the
  -- nodes/types system, but we will first develop something that
  -- produces output (so we can do test-driven refactoring, and
  -- identify the common and critical code paths)
  function mud:makeRules()
    -- first do checks, etc.
    -- TODO ;)

    -- find out which incoming and which outgoiing rules we have
    local from_device_acl_nodelist = self.mud:getNode("from-device-policy/access-lists/access-list")
    print(json.encode(from_device_acl_nodelist:toData()))
    local from_device_acl_names = {}
    -- maybe add something like findNodes("/foo/bar[*]/baz/*/name")?
    for i,node in pairs(from_device_acl_nodelist:getValue()) do
      local acl_name = node:getNode('name'):toData()
      -- find with some functionality is definitely needed in types
      -- but xpath is too complex. need to find right level.
      table.insert(from_device_acl_names, node:getNode('name'):toData())
    end
    print("[XX] from device policies:")
    print(str_join(", ", from_device_acl_names))

    -- find the actual ACL associated with it (container is called 'ace')
    --local from_device_acl_names =
    -- and here we need something like findNodes("access-list[name='aaa']")
    local from_device_acls = {}
    for i,n in pairs(from_device_acl_names) do
        local found = false
        local acl = findNodesWithProperty(self.acls, "acl", "name", n)
        --print("[XX] FOUND IT: " .. acl:getType())

        -- findNodesWherePropertyIs
        --for i,all_node in pairs(self.acls:getAll()) do
            --rint("[XX] NODE: " .. all_node:getType())
            -- this would find all "ace" nodes with the given name
            --if all_node:getType() == "container" and all_node:hasNode("ace") then
            --    print("[XX] container with ace")
            --    local ace_nodes = all_node:getNode("ace")
            --    for i,ace_node in pairs(ace_nodes:getValue()) do
            --        print("[XX] ACE_NODE TYPE: " .. ace_node:getType())
            --        if ace_node:hasNode("name") then
            --            print(ace_node:getNode("name"):getValue())
            --        end
            --        if ace_node:hasNode("name") and ace_node:getNode("name"):getValue() == n then
            --            print("[XX] WE GOT HIM")
            --        end
            --    end
            --end

            -- find all 'acl' nodes with the given name
        --end
        --if not found then error("ACL with name " .. n .. " not found in acl list") end
    end

    print(json.encode(self.acls:toData()))

  end


_M.mud = mud


return _M

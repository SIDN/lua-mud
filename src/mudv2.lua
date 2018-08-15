
-- MUD container

local json = require("cjson")
local yang = require "yang"

local _M = {}

-- ietf-access-control-list is a specialized type; the base of it is a container
local ietf_access_control_list = yang.util.subClass("ietf_access_control_list", yang.basic_types.container)
ietf_access_control_list_mt = { __index = ietf_access_control_list }
  function ietf_access_control_list:create(nodeName, mandatory)
    local new_inst = yang.basic_types.container:create(nodeName, mandatory)
    -- additional step: add the type name
    new_inst.typeName = "acl"
    setmetatable(new_inst, ietf_access_control_list_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_access_control_list:add_definition()
    local acl_list = yang.basic_types.list:create('acl')
    acl_list:add_list_node(yang.basic_types.string:create('name', true))
    acl_list:add_list_node(yang.complex_types.acl_type:create('type', false))

    local aces = yang.basic_types.container:create('aces')
    local ace_list = yang.basic_types.list:create('ace')
    ace_list:add_list_node(yang.basic_types.string:create('name'))
    local matches = yang.basic_types.choice:create('matches')

    local matches_eth = yang.basic_types.container:create('eth')
    matches_eth:add_node(yang.basic_types.mac_address:create('destination-mac-address'))
    matches_eth:add_node(yang.basic_types.mac_address:create('destination-mac-address-mask'))
    matches_eth:add_node(yang.basic_types.mac_address:create('source-mac-address'))
    matches_eth:add_node(yang.basic_types.mac_address:create('source-mac-address-mask'))
    matches_eth:add_node(yang.basic_types.eth_ethertype:create('ethertype'))

    local matches_ipv4 = yang.basic_types.container:create('ipv4')
    matches_ipv4:add_node(yang.basic_types.inet_dscp:create('dscp', false))
    matches_ipv4:add_node(yang.basic_types.uint8:create('ecn', false))
    matches_ipv4:add_node(yang.basic_types.uint16:create('length', false))
    matches_ipv4:add_node(yang.basic_types.uint8:create('ttl', false))
    matches_ipv4:add_node(yang.basic_types.uint8:create('protocol', false))
    matches_ipv4:add_node(yang.basic_types.uint8:create('ihl', false))
    matches_ipv4:add_node(yang.basic_types.bits:create('flags', false))
    matches_ipv4:add_node(yang.basic_types.uint16:create('offset', false))
    matches_ipv4:add_node(yang.basic_types.uint16:create('identification', false))
    -- TODO: -network
    matches_ipv4:add_node(yang.basic_types.string:create('ietf-acldns:dst-dnsname', false))
    matches_ipv4:add_node(yang.basic_types.string:create('ietf-acldns:src-dnsname', false))

    local matches_ipv6 = yang.basic_types.container:create('ipv6')
    matches_ipv6:add_node(yang.basic_types.inet_dscp:create('dscp', false))
    matches_ipv6:add_node(yang.basic_types.uint8:create('ecn', false))
    matches_ipv6:add_node(yang.basic_types.uint16:create('length', false))
    matches_ipv6:add_node(yang.basic_types.uint8:create('ttl', false))
    matches_ipv6:add_node(yang.basic_types.uint8:create('protocol', false))
    matches_ipv6:add_node(yang.basic_types.string:create('ietf-acldns:dst-dnsname', false))
    matches_ipv6:add_node(yang.basic_types.string:create('ietf-acldns:src-dnsname', false))
    -- TODO: -network
    -- TODO: flow-label

    local matches_tcp = yang.basic_types.container:create('tcp')
    matches_tcp:add_node(yang.basic_types.uint32:create('sequence-number', false))
    matches_tcp:add_node(yang.basic_types.uint32:create('acknowledgement-number', false))
    matches_tcp:add_node(yang.basic_types.uint8:create('offset', false))
    matches_tcp:add_node(yang.basic_types.uint8:create('reserved', false))

    local source_port_choice = yang.basic_types.choice:create('source-port', false, true)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yang.basic_types.container:create('choice-operator')
    choice_operator:add_node(yang.basic_types.string:create('operator'))
    choice_operator:add_node(yang.basic_types.uint16:create('port'))
    source_port_choice:add_choice('operator', choice_operator)
    matches_tcp:add_node(source_port_choice)

    local destination_port_choice = yang.basic_types.choice:create('destination-port', false, true)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yang.basic_types.container:create('choice-operator')
    choice_operator:add_node(yang.basic_types.string:create('operator'))
    choice_operator:add_node(yang.basic_types.uint16:create('port'))
    --choice_operator:makePresenceContainer()
    destination_port_choice:add_choice('operator2', choice_operator)
    matches_tcp:add_node(destination_port_choice)

    -- this is an augmentation from draft-mud
    -- TODO: type 'direction' (enum?)
    matches_tcp:add_node(yang.basic_types.string:create('ietf-mud:direction-initiated', false))

    local matches_udp = yang.basic_types.container:create('udp')
    matches_udp:add_node(yang.basic_types.uint16:create('length', false))
    matches_udp:add_node(yang.util.deepcopy(source_port_choice))
    matches_udp:add_node(yang.util.deepcopy(destination_port_choice))

    matches:set_named(true)
    matches:add_choice('eth', matches_eth)
    matches:add_choice('ipv4', matches_ipv4)
    matches:add_choice('tcp', matches_tcp)
    matches:add_choice('udp', matches_tcp)
    matches:add_choice('ipv6', matches_ipv6)
    ace_list:add_list_node(matches)
    aces:add_node(ace_list)

    local actions = yang.basic_types.container:create('actions')
    -- todo identityref
    actions:add_node(yang.basic_types.string:create('forwarding'))
    actions:add_node(yang.basic_types.string:create('logging', false))

    ace_list:add_list_node(actions)
    acl_list:add_list_node(aces)

    -- report: discrepancy between example and definition? (or maybe just tree)
    -- TODO: look up what to do with singular/plural, maybe that is stated somewhere
    self:add_node(acl_list)
  end
-- class ietf_access_control_list

local ietf_mud_type = yang.util.subClass("ietf_mud_type", yang.basic_types.container)
ietf_mud_type_mt = { __index = ietf_mud_type }
  function ietf_mud_type:create(nodeName, mandatory)
    local new_inst = yang.basic_types.container:create(nodeName, mandatory)
    -- additional step: add the type name
    new_inst.typeName = "mud"
    setmetatable(new_inst, ietf_mud_type_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_mud_type:add_definition()
    local c = yang.basic_types.container:create('mud')
    c:add_node(yang.basic_types.uint8:create('mud-version', 'mud-version'))
    c:add_node(yang.basic_types.inet_uri:create('mud-url', 'mud-url', true))
    c:add_node(yang.basic_types.date_and_time:create('last-update'))
    c:add_node(yang.basic_types.inet_uri:create('mud-signature', false))
    c:add_node(yang.basic_types.uint8:create('cache-validity', false))
    c:add_node(yang.basic_types.boolean:create('is-supported'))
    c:add_node(yang.basic_types.string:create('systeminfo', false))
    c:add_node(yang.basic_types.string:create('mfg-name', false))
    c:add_node(yang.basic_types.string:create('model-name', false))
    c:add_node(yang.basic_types.string:create('firmware-rev', false))
    c:add_node(yang.basic_types.inet_uri:create('documentation', false))
    c:add_node(yang.basic_types.notimplemented:create('extensions', false))

    local from_device_policy = yang.basic_types.container:create('from-device-policy')
    local access_lists = yang.basic_types.container:create('access-lists')
    local access_lists_list = yang.basic_types.list:create('access-list')
    -- todo: references
    access_lists_list:add_list_node(yang.basic_types.string:create('name'))
    access_lists:add_node(access_lists_list)
    -- this seems to be a difference between the example and the definition
    from_device_policy:add_node(access_lists)
    c:add_node(from_device_policy)

    local to_device_policy = yang.basic_types.container:create('to-device-policy')
    local access_lists = yang.basic_types.container:create('access-lists')
    local access_lists_list = yang.basic_types.list:create('access-list')
    -- todo: references
    access_lists_list:add_list_node(yang.basic_types.string:create('name'))
    access_lists:add_node(access_lists_list)
    -- this seems to be a difference between the example and the definition
    to_device_policy:add_node(access_lists)
    c:add_node(to_device_policy)

    -- it's a presence container, so we *replace* the base node list instead of adding to it
    self.yang_nodes = c.yang_nodes
  end
-- class ietf_mud_type

--local function tdump (tbl, indent)
--  if not indent then indent = 0 end
--  for k, v in pairs(tbl) do
--    formatting = string.rep("  ", indent) .. k .. ": "
--    if type(v) == "table" then
--      print(formatting)
--      tdump(v, indent+1)
--    elseif type(v) == 'boolean' then
--      print(formatting .. tostring(v))
--    else
--      print(formatting .. v)
--    end
--  end
--end

local mud_container = yang.util.subClass("mud_container", yang.basic_types.container)
mud_container_mt = { __index = mud_container }
  function mud_container:create(nodeName, mandatory)
    local new_inst = yang.basic_types.container:create(nodeName, mandatory)
    new_inst.typeName = "mud_container"
    setmetatable(new_inst, mud_container_mt)
    new_inst:add_definition()
    return new_inst
  end

  function mud_container:add_definition()
    self:add_node(ietf_mud_type:create('ietf-mud:mud', true))
     self:add_node(ietf_access_control_list:create('ietf-access-control-list:acls', true))
  end
-- mud_container

function aceToRules(ace_node)
    local rules = {}
    for i,ace in pairs(ace_node:getValue()) do
        local rulestart = "nft add rule inet "
        local v6_or_v4 = nil
        local direction = nil
        local rulematches = ""
        for i,match in pairs(ace:getNode('matches'):getChoices()) do
            if match:getName() == 'ipv4' then
                v6_or_v4 = "ip "
                for j,match_node in pairs(match.yang_nodes) do
                    if match_node:hasValue() then
                        if match_node:getName() == 'ietf-acldns:dst-dnsname' then
                            rulematches = rulematches .. "daddr " .. match_node:toData() .. " "
                        elseif match_node:getName() == 'ietf-acldns:src-dnsname' then
                            rulematches = rulematches .. "saddr " .. match_node:toData() .. " "
                        elseif match_node:getName() == 'protocol' then
                            -- this is done by virtue of it being an ipv6 option
                        elseif match_node:getName() == 'destination-port' then
                            -- TODO: check operator and/or range
                            rulematches = rulematches .. "dport " .. match_node:getChoice():getNode('port'):getValue() .. " "
                        else
                            error("NOTIMPL: unknown match type " .. match_node:getName() .. " in match rule " .. match:getName() )
                        end
                    end
                end
            elseif match:getName() == 'ipv6' then
                v6_or_v4 = "ip6 "
                for j,match_node in pairs(match.yang_nodes) do
                    if match_node:hasValue() then
                        if match_node:getName() == 'ietf-acldns:dst-dnsname' then
                            rulematches = rulematches .. "daddr " .. match_node:toData() .. " "
                        elseif match_node:getName() == 'ietf-acldns:src-dnsname' then
                            rulematches = rulematches .. "saddr " .. match_node:toData() .. " "
                        elseif match_node:getName() == 'protocol' then
                            -- this is done by virtue of it being an ipv6 option
                        elseif match_node:getName() == 'destination-port' then
                            -- TODO: check operator and/or range
                            rulematches = rulematches .. "dport " .. match_node:getChoice():getNode('port'):getValue() .. " "
                        else
                            error("NOTIMPL: unknown match type " .. match_node:getName() .. " in match rule " .. match:getName() )
                        end
                    end
                end
                -- TODO
                -- TODO
            elseif match:getName() == 'tcp' then
                rulematches = rulematches .. "tcp "
                for j,match_node in pairs(match.yang_nodes) do
                    if match_node:hasValue() then
                        if match_node:getName() == 'ietf-mud:direction-initiated' then
                            -- TODO: does this have any influence on the actual rule?
                            if match_node:toData() == 'from-device' then
                                direction = "filter output "
                            elseif match_node:toData() == 'to-device' then
                                direction = "filter input "
                            else
                                error('unknown direction-initiated: ' .. match_node:toData())
                            end
                        elseif match_node:getName() == 'source-port' then
                            -- TODO: check operator and/or range
                            rulematches = rulematches .. "sport " .. match_node:getChoice():getNode('port'):getValue() .. " "
                        elseif match_node:getName() == 'destination-port' then
                            -- TODO: check operator and/or range
                            rulematches = rulematches .. "dport " .. match_node:getChoice():getNode('port'):getValue() .. " "
                        else
                            error("NOTIMPL: unknown match type " .. match_node:getName() .. " in match rule " .. match:getName() )
                        end
                    end
                end
            else
                error('unknown match type: ' .. match:getName())
            end
        end

        local rule_action = ace:getNode("actions/forwarding"):getValue()
        if v6_or_v4 == nil then
            error('currently, we need either an ipv4 or ipv6 rule')
        end
        if direction == nil then
            -- TODO: how to determine chain/
            direction = "forward "
        end
        rule = rulestart .. direction .. v6_or_v4 .. rulematches .. rule_action
        table.insert(rules, rule)
    end
    return rules
end

local mud = {}
mud_mt = { __index = mud }
  -- create an empty mud container
  function mud:create()
    local new_inst = {}
    setmetatable(new_inst, mud_mt)
    -- default values and types go here

    new_inst.mud_container = mud_container:create('mud-container', true)
    return new_inst
  end

  function mud:parseJSON(json_str, file_name)
    local json_data, err = json.decode(json_str);
    if json_data == nil then
      error(err)
    end
    self.mud_container:fromData(yang.util.deepcopy(json_data))
    if json_data['ietf-mud:mud'] == nil then
      if file_name == nil then file_name = "<unknown>" end
      error("Top-level node 'ietf-mud:mud' not found in " .. file_name)
    end
  end

  -- parse from json file
  function mud:parseFile(json_file_name)
    local file, err = io.open(json_file_name)
    if file == nil then
      error(err)
    end
    local contents = file:read( "*a" )
    io.close( file )
    self:parseJSON(contents)
  end

  -- These are functions that might need refactoring into the
  -- nodes/types system, but we will first develop something that
  -- produces output (so we can do test-driven refactoring, and
  -- identify the common and critical code paths)
  function mud:makeRules()
    -- first do checks, etc.
    -- TODO ;)

    local rules = {}
    -- find out which incoming and which outgoiing rules we have
    local from_device_acl_nodelist = self.mud_container:getNode("ietf-mud:mud/from-device-policy/access-lists/access-list")
    -- maybe add something like findNodes("/foo/bar[*]/baz/*/name")?
    for i,node in pairs(from_device_acl_nodelist:getValue()) do
      local acl_name = node:getNode('name'):toData()
      -- find with some functionality is definitely needed in types
      -- but xpath is too complex. need to find right level.
      local found = false
      local acl = yang.findNodeWithProperty(self.mud_container, "acl", "name", acl_name)
      yang.util.table_extend(rules, aceToRules(acl:getNode('aces'):getNode('ace')))
    end

    local to_device_acl_nodelist = self.mud_container:getNode("ietf-mud:mud/to-device-policy/access-lists/access-list")
    -- maybe add something like findNodes("/foo/bar[*]/baz/*/name")?
    for i,node in pairs(to_device_acl_nodelist:getValue()) do
      local acl_name = node:getNode('name'):toData()
      -- find with some functionality is definitely needed in types
      -- but xpath is too complex. need to find right level.
      local found = false
      local acl = yang.findNodeWithProperty(self.mud_container, "acl", "name", acl_name)
      yang.util.table_extend(rules, aceToRules(acl:getNode('aces'):getNode('ace')))
    end
    return rules
  end


_M.mud = mud

--
-- currently, we assume the following initialization
-- # nft flush ruleset
--
-- Add a table:
--
-- # nft add table inet filter
--
-- Add the input, forward, and output base chains. The policy for input and forward will be to drop. The policy for output will be to accept.
--
-- # nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
-- # nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
-- # nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }
--
-- Add two regular chains that will be associated with tcp and udp:
--
-- # nft add chain inet filter TCP
-- # nft add chain inet filter UDP
--
-- Related and established traffic will be accepted:
--
-- # nft add rule inet filter input ct state related,established accept
--

return _M

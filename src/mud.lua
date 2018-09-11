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
    --local matches = yang.basic_types.choice:create('matches')
    local matches = yang.basic_types.container:create('matches')

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
    local ipv4_destination_network_choice = yang.basic_types.choice:create('destination-network', false, true)
    ipv4_destination_network_choice:set_named(false)
    local ipv4prefix = yang.complex_types.inet_ipv4_prefix:create('destination-ipv4-network')
    ipv4_destination_network_choice:add_case('destination-ipv4-network', ipv4prefix)
    matches_ipv4:add_node(ipv4_destination_network_choice, false)
    local ipv4_source_network_choice = yang.basic_types.choice:create('source-network', false, true)
    ipv4_source_network_choice:set_named(false)
    -- this should be type ipv4-prefix
    ipv4_source_network_choice:add_case('source-ipv4-network', yang.complex_types.inet_ipv4_prefix:create('source-ipv4-network'))
    matches_ipv4:add_node(ipv4_source_network_choice, false)

    -- mud augmentation
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
    local ipv6_destination_network_choice = yang.basic_types.choice:create('destination-network', false, true)
    ipv6_destination_network_choice:set_named(false)
    ipv6_destination_network_choice:add_case('destination-ipv6-network', yang.complex_types.inet_ipv6_prefix:create('destination-ipv6-network', false))
    matches_ipv6:add_node(ipv6_destination_network_choice)
    local ipv6_source_network_choice = yang.basic_types.choice:create('source-network', false, true)
    ipv6_source_network_choice:set_named(false)
    -- this should be type ipv6-prefix
    ipv6_source_network_choice:add_case('source-ipv6-network', yang.complex_types.inet_ipv6_prefix:create('source-ipv6-network'))
    matches_ipv6:add_node(ipv6_source_network_choice, false)
    -- TODO: flow-label

    local matches_tcp = yang.basic_types.container:create('tcp')
    matches_tcp:add_node(yang.basic_types.uint32:create('sequence-number', false))
    matches_tcp:add_node(yang.basic_types.uint32:create('acknowledgement-number', false))
    matches_tcp:add_node(yang.basic_types.uint8:create('offset', false))
    matches_tcp:add_node(yang.basic_types.uint8:create('reserved', false))

    -- new choice realization
    -- todo: is this mandatory?
    local source_port = yang.basic_types.container:create('source-port', false)
    local source_port_choice = yang.basic_types.choice:create('source-port', false)

    local source_port_range = yang.basic_types.container:create('port-range', false)
    source_port_range:add_node(yang.basic_types.uint16:create('lower-port'))
    source_port_range:add_node(yang.basic_types.uint16:create('upper-port'))
    source_port_choice:add_case('range', source_port_range)

    local source_port_operator = yang.basic_types.container:create('port-operator', false)
    source_port_operator:add_node(yang.basic_types.string:create('operator', false))
    source_port_operator:add_node(yang.basic_types.uint16:create('port'))
    source_port_choice:add_case('operator', source_port_operator)

    source_port:add_node(source_port_choice)
    matches_tcp:add_node(source_port)

    local destination_port = yang.basic_types.container:create('destination-port', false)
    local destination_port_choice = yang.basic_types.choice:create('destination-port2', false)

    local destination_port_range = yang.basic_types.container:create('port-range', false)
    destination_port_range:add_node(yang.basic_types.uint16:create('lower-port'))
    destination_port_range:add_node(yang.basic_types.uint16:create('upper-port'))
    destination_port_choice:add_case('range', destination_port_range)

    local destination_port_operator = yang.basic_types.container:create('port-operator', false)
    destination_port_operator:add_node(yang.basic_types.string:create('operator', false))
    destination_port_operator:add_node(yang.basic_types.uint16:create('port'))
    destination_port_choice:add_case('operator', destination_port_operator)

    destination_port:add_node(destination_port_choice)
    matches_tcp:add_node(destination_port)

    -- this is an augmentation from draft-mud
    -- TODO: type 'direction' (enum?)
    matches_tcp:add_node(yang.basic_types.string:create('ietf-mud:direction-initiated', false))

    local matches_udp = yang.basic_types.container:create('udp')
    matches_udp:add_node(yang.basic_types.uint16:create('length', false))
    matches_udp:add_node(yang.util.deepcopy(source_port_choice))
    matches_udp:add_node(yang.util.deepcopy(destination_port_choice))

    local matches_l1_choice = yang.basic_types.choice:create('l1', false)
    local matches_l2_choice = yang.basic_types.choice:create('l2', false)
    local matches_l3_choice = yang.basic_types.choice:create('l3', false)
    local matches_l4_choice = yang.basic_types.choice:create('l4', false)
    local matches_l5_choice = yang.basic_types.choice:create('l5', false)

    matches_l1_choice:add_case('eth', matches_eth)
    matches_l3_choice:add_case('tcp', matches_tcp)
    matches_l4_choice:add_case('udp', matches_udp)
    matches_l5_choice:add_case('ipv6', matches_ipv6)
    matches_l2_choice:add_case('ipv4', matches_ipv4)

    matches:add_node(matches_l1_choice)
    matches:add_node(matches_l3_choice)
    matches:add_node(matches_l4_choice)
    matches:add_node(matches_l5_choice)
    matches:add_node(matches_l2_choice)

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
    new_inst.typeName = "ietf-mud:mud"
    setmetatable(new_inst, ietf_mud_type_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_mud_type:add_definition()
    local c = yang.basic_types.container:create('ietf-mud:mud')
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
    for i,n in pairs(self.yang_nodes) do
      n:setParent(self)
    end
  end
-- class ietf_mud_type

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

function ipMatchToRulePart(match_node)
  rulepart = ""

  if match_node:getName() == 'ietf-acldns:dst-dnsname' then
      rulepart = rulepart .. "daddr " .. match_node:toData() .. " "
  elseif match_node:getName() == 'ietf-acldns:src-dnsname' then
      rulepart = rulepart .. "saddr " .. match_node:toData() .. " "
  elseif match_node:getName() == 'protocol' then
      -- this is done by virtue of it being an ipv6 option
  elseif match_node:getName() == 'destination-port' then
      -- TODO: check operator and/or range
      rulepart = rulepart .. "dport " .. match_node:getActiveCase():getNode('port'):getValue() .. " "
  else
      error("NOTIMPL: unknown match type " .. match_node:getName() .. " in match rule " .. match:getName() )
  end

  return rulepart
end

function getAddresses(name, family)
  local result = {}
  local hostaddrs = socket.dns.getaddrinfo(name)
  if hostaddrs then
    for i,a in pairs(hostaddrs) do
      if family == nil or a.family == family then
        table.insert(result, a.addr)
      end
    end
  end
  return result
end

function getIPv6Addresses(name)
  return getAddresses(name, 'inet6')
end

function getIPv4Addresses(name)
  return getAddresses(name, 'inet')
end

-- returns true if a node was (or should have been) replaced; this
-- is so if the data contains a value for the dnsname_str in the
-- family_str, whether or not it actually resolves to an ip address
function replaceDNSNameNode(new_nodes, node, family_str, dnsname_str, network_source_or_dest, network_source_or_dest_v)
  local nd = node:toData()
  if nd[family_str] and nd[family_str][dnsname_str] then
    local dnsname = nd[family_str][dnsname_str]
    local addrs = getIPv6Addresses(dnsname)
    if table.getn(addrs) == 0 then
      print("WARNING: " .. dnsname .. " does not resolve to any " .. family_str .. " addresses")
    end
    for i,a in pairs(addrs) do
      local nn = yang.util.deepcopy(node)
      nd[family_str][dnsname_str] = nil
      -- add new rule here ((TODO))
      --nd[family_str][network_source_or_dest] = {}
      if family_str == 'ipv6' then
        --nd[family_str][network_source_or_dest][network_source_or_dest_v] = a .. "/128"
        nd[family_str][network_source_or_dest_v] = a .. "/128"
      else
        nd[family_str][network_source_or_dest_v] = a .. "/32"
      end
      --nn:fromData_noerror(nd)
      nn:clearData()
      nn:fromData_noerror(nd)
      --nn:fromData_noerror(nd)
      table.insert(new_nodes, nn)
    end
    return true
  end
  return false
end

function aceToRulesIPTables(ace_node)
  local nodes = ace_node:getAll()
  -- small trick, use getParent() so we can have a path request on the entire list
  local nodes = yang.findNodes(ace_node:getParent(), "ace[*]/matches")
  local paths = {}

  --
  -- pre-processing
  --

  -- IPTables does not support hostname-based rules, so in the case of
  -- a dnsname rule, we look up the address(es), and duplicate the rule
  -- for each (v4 or v6 depending on match type)
  local new_nodes = {}
  for i,n in pairs(nodes) do
    local nd = n:toData()
    table.insert(paths, n:getPath())
    -- need to make it into destination-ipv4-network, destination-ipv6-network,
    -- source-ipv4-network or source-ipv6-network, depending on what it was
    -- (ipv6/destination-dnsname, etc.)
    local node_replaced = false
    if replaceDNSNameNode(new_nodes, n, "ipv6", "ietf-acldns:src-dnsname", 'source-network', 'source-ipv6-network') then
      node_replaced = true
    end
    if replaceDNSNameNode(new_nodes, n, "ipv6", "ietf-acldns:dst-dnsname", 'destination-network', 'destination-ipv6-network') then
      node_replaced = true
    end
    if replaceDNSNameNode(new_nodes, n, "ipv4", "ietf-acldns:src-dnsname", 'source-network', 'source-ipv4-network') then
      node_replaced = true
    end
    if replaceDNSNameNode(new_nodes, n, "ipv4", "ietf-acldns:dst-dnsname", 'destination-network', 'destination-ipv4-network') then
      node_replaced = true
    end

    if not node_replaced then
      table.insert(new_nodes, n)
    end
  end

  --
  -- conversion to actual rules
  --
  for i,n in pairs(new_nodes) do
    table.insert(paths, n:getPath())
  end

  return paths
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
    self.mud_container:fromData_noerror(yang.util.deepcopy(json_data))
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
_M.mud = mud


return _M

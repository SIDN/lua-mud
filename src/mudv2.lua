
-- MUD container

local json = require("cjson")
local yt = require "yang_types"

local _M = {}

-- ietf-access-control-list is a specialized type; the base of it is a container
local ietf_access_control_list = inheritsFrom(yt.container)
ietf_access_control_list_mt = { __index = ietf_access_control_list }
  function ietf_access_control_list:create(mandatory)
    local new_inst = yt.container.create(mandatory)
    -- additional step: add the type name
    new_inst.typeName = "acl"
    setmetatable(new_inst, ietf_access_control_list_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_access_control_list:add_definition()
    local acl_list = yt.list:create()
    acl_list:set_entry_node('name', yt.string:create(true))
    acl_list:set_entry_node('type', yt.acl_type:create(false))

    local aces = yt.container:create()
    local ace_list = yt.list:create()
    ace_list:set_entry_node('name', yt.string:create())
    local matches = yt.choice:create()

    local matches_eth = yt.container:create()
    matches_eth:add_node('destination-mac-address', yt.yang_mac_address:create())
    matches_eth:add_node('destination-mac-address-mask', yt.yang_mac_address:create())
    matches_eth:add_node('source-mac-address', yt.yang_mac_address:create())
    matches_eth:add_node('source-mac-address-mask', yt.yang_mac_address:create())
    matches_eth:add_node('ethertype', yt.eth_ethertype:create())
    
    local matches_ipv4 = yt.container:create()
    matches_ipv4:add_node('dscp', yt.inet_dscp:create(false))
    matches_ipv4:add_node('ecn', yt.uint8:create(false))
    matches_ipv4:add_node('length', yt.uint16:create(false))
    matches_ipv4:add_node('ttl', yt.uint8:create(false))
    matches_ipv4:add_node('protocol', yt.uint8:create(false))
    matches_ipv4:add_node('ihl', yt.uint8:create(false))
    matches_ipv4:add_node('flags', yt.bits:create(false))
    matches_ipv4:add_node('offset', yt.uint16:create(false))
    matches_ipv4:add_node('identification', yt.uint16:create(false))
    -- TODO: -network
    --matches_ipv4:add_node('', yt.:create())
    --matches_ipv4:add_node('', yt.:create())
    matches_ipv4:add_node('ietf-acldns:dst-dnsname', yt.string:create(false))
    matches_ipv4:add_node('ietf-acldns:src-dnsname', yt.string:create(false))

    local matches_ipv6 = yt.container:create()
    matches_ipv6:add_node('dscp', yt.inet_dscp:create(false))
    matches_ipv6:add_node('ecn', yt.uint8:create(false))
    matches_ipv6:add_node('length', yt.uint16:create(false))
    matches_ipv6:add_node('ttl', yt.uint8:create(false))
    matches_ipv6:add_node('protocol', yt.uint8:create(false))
    matches_ipv6:add_node('ietf-acldns:dst-dnsname', yt.string:create(false))
    matches_ipv6:add_node('ietf-acldns:src-dnsname', yt.string:create(false))
    -- TODO: -network
    -- TODO: flow-label

    local matches_tcp = yt.container:create()
    matches_tcp:add_node('sequence-number', yt.uint32:create(false))
    matches_tcp:add_node('acknowledgement-number', yt.uint32:create(false))
    matches_tcp:add_node('offset', yt.uint8:create(false))
    matches_tcp:add_node('reserved', yt.uint8:create(false))

    local source_port_choice = yt.choice:create(false, true)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yt.container:create()
    choice_operator:add_node('operator', yt.string:create())
    choice_operator:add_node('port', yt.uint16:create())
    source_port_choice:add_choice('operator', choice_operator)
    matches_tcp:add_node('source-port', source_port_choice)

    local destination_port_choice = yt.choice:create(false, true)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yt.container:create()
    choice_operator:add_node('operator', yt.string:create())
    choice_operator:add_node('port', yt.uint16:create())
    --choice_operator:makePresenceContainer()
    destination_port_choice:add_choice('operator2', choice_operator)
    matches_tcp:add_node('destination-port', destination_port_choice)

    -- this is an augmentation from draft-mud
    -- TODO: type 'direction' (enum?)
    matches_tcp:add_node('ietf-mud:direction-initiated', yt.string:create(false))

    matches:add_choice('eth', matches_eth)
    matches:add_choice('ipv4', matches_ipv4)
    matches:add_choice('tcp', matches_tcp)
    matches:add_choice('ipv6', matches_ipv6)
    ace_list:set_entry_node('matches', matches)
    aces:add_node('ace', ace_list)

    local actions = yt.container:create()
    -- todo identityref
    actions:add_node('forwarding', yt.string:create())
    actions:add_node('logging', yt.string:create(false))
    
    ace_list:set_entry_node('actions', actions)
    acl_list:set_entry_node('aces', aces)

    -- report: discrepancy between example and definition? (or maybe just tree)
    -- TODO: look up what to do with singular/plural, maybe that is stated somewhere
    self:add_node('acl', acl_list)
  end
-- class ietf_access_control_list

local ietf_mud_type = inheritsFrom(yt.container)
ietf_mud_type_mt = { __index = ietf_mud_type }
  function ietf_mud_type:create(mandatory)
    local new_inst = yt.container.create(mandatory)
    -- additional step: add the type name
    new_inst.typeName = "mud"
    setmetatable(new_inst, ietf_mud_type_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_mud_type:add_definition()
    local c = yt.container:create()
    c:add_node('mud-version', yt.uint8:create())
    c:add_node('mud-url', yt.inet_uri:create(true))
    c:add_node('last-update', yt.yang_date_and_time:create())
    c:add_node('mud-signature', yt.inet_uri:create(false))
    c:add_node('cache-validity', yt.uint8:create(false))
    c:add_node('is-supported', yt.boolean:create())
    c:add_node('systeminfo', yt.string:create(false))
    c:add_node('mfg-name', yt.string:create(false))
    c:add_node('model-name', yt.string:create(false))
    c:add_node('firmware-rev', yt.string:create(false))
    c:add_node('documentation', yt.inet_uri:create(false))
    c:add_node('extensions', yt.notimplemented:create(false))

    local from_device_policy = yt.container:create()
    local access_lists = yt.container:create()
    local access_lists_list = yt.list:create()
    -- todo: references
    access_lists_list:set_entry_node('name', yt.string:create())
    access_lists:add_node('access-list', access_lists_list)
    -- this seems to be a difference between the example and the definition
    from_device_policy:add_node('access-lists', access_lists)
    c:add_node('from-device-policy', from_device_policy)

    local to_device_policy = yt.container:create()
    local access_lists = yt.container:create()
    local access_lists_list = yt.list:create()
    -- todo: references
    access_lists_list:set_entry_node('name', yt.string:create())
    access_lists:add_node('access-list', access_lists_list)
    -- this seems to be a difference between the example and the definition
    to_device_policy:add_node('access-lists', access_lists)
    c:add_node('to-device-policy', to_device_policy)

    -- it's a presence container, so we *replace* the base node list instead of adding to it
    self.yang_nodes = c.yang_nodes
  end
-- class ietf_mud_type


local mud = {}
mud_mt = { __index = mud }
  -- create an empty mud container
  function mud:create()
    local new_inst = {}
    setmetatable(new_inst, mud_mt)
    -- default values and types go here
    
    new_inst.mud = ietf_mud_type:create()

    --local acl = yt.container:create()
    new_inst.acls = ietf_access_control_list:create()
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
    local from_device_acls = {}
    for i,node in pairs(from_device_acl_nodelist:getValue()) do
      local acl_name = node:getNode('name'):toData()
      -- find with some functionality is definitely needed in types
      -- but xpath is too complex. need to find right level.
      
      table.insert(from_device_acl_names, node:getNode('name'):toData())
    end
    print("[XX] from device policies:")
    print(str_join(", ", from_device_acl_names))
    --local from_device_acl_names = 
    
  end


_M.mud = mud


return _M


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
    acl_list:set_entry_element('name', yt.string:create(true))
    acl_list:set_entry_element('type', yt.acl_type:create(false))

    local aces = yt.container:create()
    local ace_list = yt.list:create()
    ace_list:set_entry_element('name', yt.string:create())
    local matches = yt.choice:create()

    local matches_eth = yt.container:create()
    matches_eth:add_yang_element('destination-mac-address', yt.yang_mac_address:create())
    matches_eth:add_yang_element('destination-mac-address-mask', yt.yang_mac_address:create())
    matches_eth:add_yang_element('source-mac-address', yt.yang_mac_address:create())
    matches_eth:add_yang_element('source-mac-address-mask', yt.yang_mac_address:create())
    matches_eth:add_yang_element('ethertype', yt.eth_ethertype:create())
    
    local matches_ipv4 = yt.container:create()
    matches_ipv4:add_yang_element('dscp', yt.inet_dscp:create(false))
    matches_ipv4:add_yang_element('ecn', yt.uint8:create(false))
    matches_ipv4:add_yang_element('length', yt.uint16:create(false))
    matches_ipv4:add_yang_element('ttl', yt.uint8:create(false))
    matches_ipv4:add_yang_element('protocol', yt.uint8:create(false))
    matches_ipv4:add_yang_element('ihl', yt.uint8:create(false))
    matches_ipv4:add_yang_element('flags', yt.bits:create(false))
    matches_ipv4:add_yang_element('offset', yt.uint16:create(false))
    matches_ipv4:add_yang_element('identification', yt.uint16:create(false))
    -- TODO: -network
    --matches_ipv4:add_yang_element('', yt.:create())
    --matches_ipv4:add_yang_element('', yt.:create())
    matches_ipv4:add_yang_element('ietf-acldns:dst-dnsname', yt.string:create(false))
    matches_ipv4:add_yang_element('ietf-acldns:src-dnsname', yt.string:create(false))

    local matches_ipv6 = yt.container:create()
    matches_ipv6:add_yang_element('dscp', yt.inet_dscp:create(false))
    matches_ipv6:add_yang_element('ecn', yt.uint8:create(false))
    matches_ipv6:add_yang_element('length', yt.uint16:create(false))
    matches_ipv6:add_yang_element('ttl', yt.uint8:create(false))
    matches_ipv6:add_yang_element('protocol', yt.uint8:create(false))
    matches_ipv6:add_yang_element('ietf-acldns:dst-dnsname', yt.string:create(false))
    matches_ipv6:add_yang_element('ietf-acldns:src-dnsname', yt.string:create(false))
    -- TODO: -network
    -- TODO: flow-label

    local matches_tcp = yt.container:create()
    matches_tcp:add_yang_element('sequence-number', yt.uint32:create(false))
    matches_tcp:add_yang_element('acknowledgement-number', yt.uint32:create(false))
    matches_tcp:add_yang_element('offset', yt.uint8:create(false))
    matches_tcp:add_yang_element('reserved', yt.uint8:create(false))

    local source_port_choice = yt.choice:create(false)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yt.container:create()
    choice_operator:add_yang_element('operator', yt.string:create())
    choice_operator:add_yang_element('port', yt.uint16:create())
    source_port_choice:add_choice('operator', choice_operator)
    --source_port_choice:add_choice('operator', 
    --source_port_choice:add_choice('
    print("[XX] ADDING SOURCE PORT CHOICE " .. json.encode(source_port_choice:isMandatory()))
    matches_tcp:add_yang_element('source-port', source_port_choice)

    local destination_port_choice = yt.choice:create(false)
    -- todo: full implementation of pf:port-range-or-operator
    local choice_operator = yt.container:create()
    choice_operator:add_yang_element('operator', yt.string:create())
    choice_operator:add_yang_element('port', yt.uint16:create())
    destination_port_choice:add_choice('operator', choice_operator)
    --destination_port_choice:add_choice('operator', 
    --destination_port_choice:add_choice('
    print("[XX] ADDING destination PORT CHOICE " .. json.encode(destination_port_choice:isMandatory()))
    matches_tcp:add_yang_element('destination-port', destination_port_choice)

    -- this is an augmentation from draft-mud
    -- TODO: type 'direction' (enum?)
    matches_tcp:add_yang_element('ietf-mud:direction-initiated', yt.string:create(false))

    matches:add_choice('eth', matches_eth)
    matches:add_choice('ipv4', matches_ipv4)
    matches:add_choice('tcp', matches_tcp)
    matches:add_choice('ipv6', matches_ipv6)
    ace_list:set_entry_element('matches', matches)
    aces:add_yang_element('ace', ace_list)

    local actions = yt.container:create()
    -- todo identityref
    actions:add_yang_element('forwarding', yt.string:create())
    actions:add_yang_element('logging', yt.string:create(false))
    
    ace_list:set_entry_element('actions', actions)
    acl_list:set_entry_element('aces', aces)

    -- report: discrepancy between example and definition? (or maybe just tree)
    -- TODO: look up what to do with singular/plural, maybe that is stated somewhere
    self:add_yang_element('acl', acl_list)
  end
-- class ietf_access_control_list

local ietf_mud_type = inheritsFrom(yt.container)
ietf_mud_type_mt = { __index = ietf_mud_type }
  function ietf_mud_type:create(mandatory)
    local new_inst = yt.container.create(mandatory)
    -- additional step: add the type name
    new_inst.typeName = "acl"
    setmetatable(new_inst, ietf_mud_type_mt)
    new_inst:add_definition()
    return new_inst
  end

  function ietf_mud_type:add_definition()
    local c = yt.container:create()
    c:add_yang_element('mud-version', yt.uint8:create())
    c:add_yang_element('mud-url', yt.inet_uri:create(true))
    c:add_yang_element('last-update', yt.yang_date_and_time:create())
    c:add_yang_element('mud-signature', yt.inet_uri:create(false))
    c:add_yang_element('cache-validity', yt.uint8:create(false))
    c:add_yang_element('is-supported', yt.boolean:create())
    c:add_yang_element('systeminfo', yt.string:create(false))
    c:add_yang_element('mfg-name', yt.string:create(false))
    c:add_yang_element('model-name', yt.string:create(false))
    c:add_yang_element('firmware-rev', yt.string:create(false))
    c:add_yang_element('documentation', yt.inet_uri:create(false))
    c:add_yang_element('extensions', yt.notimplemented:create(false))

    local from_device_policy = yt.container:create()
    local access_lists = yt.container:create()
    local access_lists_list = yt.list:create()
    -- todo: references
    access_lists_list:set_entry_element('name', yt.string:create())
    access_lists:add_yang_element('access-list', access_lists_list)
    -- this seems to be a difference between the example and the definition
    from_device_policy:add_yang_element('access-lists', access_lists)
    c:add_yang_element('from-device-policy', from_device_policy)

    local to_device_policy = yt.container:create()
    local access_lists = yt.container:create()
    local access_lists_list = yt.list:create()
    -- todo: references
    access_lists_list:set_entry_element('name', yt.string:create())
    access_lists:add_yang_element('access-list', access_lists_list)
    -- this seems to be a difference between the example and the definition
    to_device_policy:add_yang_element('access-lists', access_lists)
    c:add_yang_element('to-device-policy', to_device_policy)

    -- it's a presence container, so we *replace* the base element list instead of adding to it
    self.yang_elements = c.yang_elements
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
    print("[XX] parse: " .. json_file_name)
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
      error("Top-level element 'ietf-mud:mud' not found in " .. json_file_name)
    end
    local mud_data = json_data['ietf-mud:mud']
    self.mud:fromData(mud_data)

    if json_data['ietf-access-control-list:acls'] == nil then
      error("Top-level element 'ietf-access-control-list:acls' not found in " .. json_file_name)
    end
    local acls_data = json_data['ietf-access-control-list:acls']
    self.acls:fromData(acls_data)

    --self.acls:parseJson(json_data)
  end

  function mud:print()
    --self.mud:print()
    --self.acls:print()
    local data = self.acls:toData()
    print(json.encode(data))
  end
_M.mud = mud


return _M

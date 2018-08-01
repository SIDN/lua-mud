
-- MUD container

local json = require("cjson")
local yt = require "yang_types"

local _M = {}

local acl = {}
acl_mt = { __index = acl }
  function acl:create()
    local new_inst = {}
    setmetatable(new_inst, acl_mt)
    local acl_list = yt.list:create()
    acl_list:set_entry_element('name', yt.string:create())
    acl_list:set_entry_element('type', yt.acl_type:create(false))
    new_inst.acls = acl_list
    new_inst.yang_elements = {}
    new_inst.yang_elements['acls'] = acl_list
    --acl_list:set_entry_element('type', yt.acl_type:create(false))
    return new_inst
  end

  function acl:parseJson(json_data)
    -- main element is ietf-access-control-list:acls
    if json_data['ietf-access-control-list:acls'] == nil then
      error("Top-level element 'ietf-access-control-list:acls' not found in " .. json_file_name)
    end
    local acls_data = json_data['ietf-access-control-list:acls']
    for element_name, element in pairs(self.yang_elements) do
      print("Trying yang element " .. element_name)
      if acls_data[element_name] ~= nil then
        -- should we make setValue smart or check at this point whether the element target is a special type
        -- list a yt.list or yt.container?
        if element:getType() ~= 'list' then
          element:setValue(acls_data[element_name])
        else
          for _,json_element in pairs(acls_data[element_name]) do
            -- we are now in a bit of a meta-level, essentially we need to do the same as for 'main' objects, but
            -- now for each element in the list, and with the yang elements 'entry_elements' data
            -- this is essentially the same loop/functionality as
            -- THIS NEEDS HEAVY REFACTORING
            local new_el = element:add_element()
            for list_element_name, list_element in pairs(new_el.yang_elements) do
              print("Trying yang (sub)element " .. list_element_name)
              if json_element[list_element_name] ~= nil then
                list_element:setValue(json_element[list_element_name])
              elseif list_element:isMandatory() then
                error('mandatory element ' .. list_element_name .. ' not found')
              end
            end
          end
        end
      elseif element:isMandatory() then
        error('mandatory element ' .. element_name .. ' not found')
      end
    end
    print("[XX] DONEDONEDONE")
  end
_M.acl = acl


local mud = {}
mud_mt = { __index = mud }
  -- create an empty mud container
  function mud:create()
    local new_inst = {}
    setmetatable(new_inst, mud_mt)
    -- default values and types go here
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

    
    new_inst.mud = c

    --local acl = yt.container:create()
    local acl_list = yt.list:create()
    acl_list:set_entry_element('name', yt.string:create(true))
    acl_list:set_entry_element('type', yt.acl_type:create(false))

    local aces = yt.container:create()
    local ace_list = yt.list:create()
    ace_list:set_entry_element('name', yt.string:create())
    local matches = yt.case:create()

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

    matches:add_case('eth', matches_eth)
    matches:add_case('ipv4', matches_ipv4)
    matches:add_case('tcp', matches_tcp)
    matches:add_case('ipv6', matches_ipv6)
    ace_list:set_entry_element('matches', matches)
    aces:add_yang_element('ace', ace_list)

    local actions = yt.container:create()
    -- todo identityref
    actions:add_yang_element('forwarding', yt.string:create())
    actions:add_yang_element('logging', yt.string:create(false))
    
    ace_list:set_entry_element('actions', actions)
    acl_list:set_entry_element('aces', aces)

    new_inst.acls = acl_list

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
    print("[XX] CALLING ACLS fromData() with:")
    print(json.encode(acls_data['acl']))
    self.acls:fromData(acls_data['acl'])

    --self.acls:parseJson(json_data)
  end

  function mud:print()
    --self.mud:print()
    --self.acls:print()
    local data = self.acls:toData()
    print(json.encode(data))
  end

  function mud:oldprint()
    for element_name, element in pairs(self.yang_elements) do
      if element:hasValue() then
        print(element_name .. ": " .. element:getValueAsString())
      else
        print(element_name .. ": <not set>")
      end
    end
    for element_name, element in pairs(self.acls.yang_elements) do
      if element:hasValue() then
        print(element_name .. ": " .. element:getValueAsString())
      else
        print(element_name .. ": <not set>")
      end
    end
  end

  -- fetch and parse from url?
  -- todo
_M.mud = mud


return _M

-- MUD container

local json = require("cjson")
local yang = require "yang"

local _M = {}

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
    self:add_node(yang.complex_types.ietf_access_control_list:create('ietf-access-control-list:acls', true))
  end
-- mud_container

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

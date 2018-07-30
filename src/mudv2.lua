
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
    new_inst.mud = c

    local a = yt.container:create()
    local a_l = yt.list:create()


    a_l:set_entry_element('name', yt.string:create(true))
    a_l:set_entry_element('type', yt.acl_type:create(false))
    --new_inst.acls = acl_list
    --new_inst.yang_elements = {}
    --new_inst.yang_elements['acls'] = acl_list
    --a:add_yang_element('acl', a_l)
    new_inst.acls = a_l

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
    self.mud:print()
    self.acls:print()
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

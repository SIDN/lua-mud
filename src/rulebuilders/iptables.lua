local yang = require("yang")

local _M = {}

local RuleBuilder = {}
RuleBuilder_mt = { __index = RuleBuilder }

function _M.create_rulebuilder()
  local new_inst = {}
  new_inst.name = "iptables"
  setmetatable(new_inst, RuleBuilder_mt)
  return new_inst
end

function RuleBuilder:build_rules(mud, settings)
  print("[XX] BUILDING IPTABLES RULES NOW. sort of")

  local rules = {}
  -- find out which incoming and which outgoiing rules we have
  local from_device_acl_nodelist = mud.mud_container:getNode("ietf-mud:mud/from-device-policy/access-lists/access-list")
  -- maybe add something like findNodes("/foo/bar[*]/baz/*/name")?
  for i,node in pairs(from_device_acl_nodelist:getValue()) do
    local acl_name = node:getNode('name'):toData()
    -- find with some functionality is definitely needed in types
    -- but xpath is too complex. need to find right level.
    local found = false
    local acl = yang.findNodeWithProperty(mud.mud_container, "acl", "name", acl_name)
    yang.util.table_extend(rules, aceToRulesIPTables(acl:getNode('aces'):getNode('ace')))
  end

  local to_device_acl_nodelist = mud.mud_container:getNode("ietf-mud:mud/to-device-policy/access-lists/access-list")
  -- maybe add something like findNodes("/foo/bar[*]/baz/*/name")?
  for i,node in pairs(to_device_acl_nodelist:getValue()) do
    local acl_name = node:getNode('name'):toData()
    -- find with some functionality is definitely needed in types
    -- but xpath is too complex. need to find right level.
    local found = false
    local acl = yang.findNodeWithProperty(mud.mud_container, "acl", "name", acl_name)
    yang.util.table_extend(rules, aceToRulesIPTables(acl:getNode('aces'):getNode('ace')))
  end
  return rules
end

function _M:apply_rules()
  error("notimpl")
end

function _M:remove_rules()
  error("notimpl")
end

_M.RuleBuilder = RuleBuilder

return _M


-- This class holds the environment information that rulebuilders
-- need, such as the local network, and the information about the
-- device to build rules for

-- Note: in the future, we should have an auto-detect option for at
-- least the network here. May need to have a plugin structure though.

local _M = {}

local MudEnvironment = {}
MudEnvironment_mt = { __index = MudEnvironment }

_M.create = function ()
  local newinst = {}
  setmetatable(newinst, MudEnvironment_mt)
  newinst.network = nil
  newinst.device_mac = nil
  newinst.device_ipv4 = nil
  newinst.device_ipv6 = nil
  return newinst
end

function MudEnvironment:setNetwork(network)
  self.network = network
end

function MudEnvironment:getNetwork(network)
  return self.network
end

function MudEnvironment:setDeviceMac(mac)
  self.device_mac = mac
end

function MudEnvironment:getDeviceMac()
  return self.device_mac
end

function MudEnvironment:setDeviceIPv4(ip)
  self.device_ipv4 = ip
end

function MudEnvironment:getDeviceIPv4()
  return self.device_ipv4
end

function MudEnvironment:setDeviceIPv6(ip)
  self.device_ipv6 = ip
end

function MudEnvironment:getDeviceIPv6()
  return self.device_ipv6
end

function MudEnvironment:print()
  if self.network == nil then
    print("Network: not set")
  else
    print("Network: " .. self.network)
  end
  if self.device_mac == nil then
    print("Device MAC: not set")
  else
    print("Device MAC: " .. self.device_mac)
  end
  if self.device_ipv4 == nil then
    print("Device IPv4: not set")
  else
    print("Device IPv4: " .. self.device_ipv4)
  end
  if self.device_ipv6 == nil then
    print("Device IPv6: not set")
  else
    print("Device IPv6: " .. self.device_ipv6)
  end
end

return _M

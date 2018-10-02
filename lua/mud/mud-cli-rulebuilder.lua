--
-- Implementation of the command line interface as called by 'lua-mud(1)'
--

local lua_mud = require 'mud.mud'
local lua_mud_environment = require 'mud.mud_environment'

local iptables_rb = require("mud.rulebuilders.iptables")

local mud_cli = {}

--
-- internal functions
--
function help(rcode, error_msg)
  if error_msg ~= nil then
    print("Error: " .. error_msg)
    print("")
  end
  print("Usage: lua-mud-cli-rulebuilder [options] <mudfile>")
  print("Reads <mudfile>, outputs iptables commands (work in progress)")
  print("")
  print("Options:")
  print("-h: show this help")
  print("-v: verbose mode")
  print("-i <ip addres>: (internal) IP address of the device to build rules for")
  print("-n <network ip address>: (internal) IP address of the local network to build rules for")
  print("-a: Apply the rules (execute the commands)")
  print("-r: Remove the rules (execute the removal commands")
  os.exit(rcode)
end

function parse_args(args)
  local mudfile = nil
  local mac_address = nil
  local network = nil
  local ipv4_address = nil
  local ipv6_address = nil
  local apply_rules = false
  local remove_rules = false
  local verbose = false

  -- set skip to true in the loop when encountering a flag that has
  -- an argument
  skip = false
  for i = 1,table.getn(args) do
    if skip then
      skip = false
    elseif arg[i] == "-h" then
      help()
    elseif arg[i] == "-m" then
      skip = true
      mac_address = arg[i+1]
    elseif arg[i] == "-4" then
      skip = true
      ipv4_address = arg[i+1]
    elseif arg[i] == "-6" then
      skip = true
      ipv6_address = arg[i+1]
    elseif arg[i] == "-n" then
      skip = true
      network = arg[i+1]
    elseif arg[i] == "-a" then
      apply_rules = true
    elseif arg[i] == "-r" then
      remove_rules = true
    elseif arg[i] == "-v" then
      verbose = true
    else
      if mudfile == nil then
        mudfile = arg[i]
        print("MUDFILE: " .. mudfile)
      else help(1, "Too many arguments at " .. table.getn(args) .. " (" .. arg[i] .. ")")
      end
    end
  end

  if mudfile == nil then help(1, "Missing argument: <mudfile>") end

  return ipv4_address, ipv6_address, mac_address, network, mudfile, apply_rules, remove_rules, verbose
end


--
-- external functions
--
function main(args)
  local ipv4_address, ipv6_address, mac, network, mudfile, apply_rules, remove_rules, verbose = parse_args(args)
  local mud = lua_mud.mud:create()
  mud:parseFile(mudfile)
  --local mud, err = lua_mud.mud_create_from_file(mudfile)
  builder = iptables_rb.create_rulebuilder()
  local environment = lua_mud_environment.create()
  environment:setDeviceIPv4(ipv4_address)
  environment:setDeviceIPv6(ipv6_address)
  environment:setDeviceMac(mac)
  environment:setNetwork(network)
  environment:print()
  local rules = builder:build_rules(mud, environment, remove_rules)
  if verbose then
    for i, rule in pairs(rules) do
      print(rule)
    end
  end
  if apply_rules or remove_rules then
    for i, rule in pairs(rules) do
      os.execute(rule)
    end
  end
end

mud_cli.main = main
return mud_cli

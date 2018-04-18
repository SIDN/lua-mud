package = "luamud"
version = "0.1-1"
source = {
   url = "git+https://github.com/SIDN/luamud"
}
description = {
   summary = "A Manufacturer Usage Description (MUD) library in Lua",
   detailed = [[
       Work in progress
   ]],
   homepage = "https://github.com/SIDN/luamud",
   license = "GPLv3"
}
dependencies = {
   "cjson >= 2.0.0-1"
}
build = {
   type = "builtin",
   modules = {
      luamud = "src/luamud.lua"
   }
}

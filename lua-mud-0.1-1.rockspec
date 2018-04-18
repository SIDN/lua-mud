package = "lua-mud"
version = "0.1-1"
source = {
    url = "git+https://github.com/SIDN/lua-mud"
}
description = {
    summary = "A Manufacturer Usage Description (MUD) library in Lua",
    detailed = [[
        Work in progress
    ]],
    homepage = "https://github.com/SIDN/lua-mud",
    license = "GPLv3",
}
dependencies = {
    "lua-cjson >= 2.0.0-1",
}
build = {
    type = "builtin",
    modules = {
        mud = "src/lua-mud.lua",
        mud_cli = "src/lua-mud-cli.lua",
    },
    install = {
        bin = { "bin/lua-mud" }
    },
}

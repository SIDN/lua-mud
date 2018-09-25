all:
	LUA_PATH="../lua/mud/?.lua;${LUA_PATH}" ./test_all.lua

debug:
	LUA_PATH="../lua/mud/?.lua;${LUA_PATH}" ./test_all_debug.lua

coverage:
	LUA_PATH="../lua/mud/?.lua;${LUA_PATH}" lua -lluacov ./test_all.lua
	luacov ../lua/mud

all:
	LUA_PATH="../src/?.lua;${LUA_PATH}" ./test_all.lua

debug:
	LUA_PATH="../src/?.lua;${LUA_PATH}" ./test_all_debug.lua

coverage:
	LUA_PATH="../src/?.lua;${LUA_PATH}" lua -lluacov ./test_all.lua
	luacov ../src

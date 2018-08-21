#!/usr/bin/lua
require 'test_util'
require 'test_yang_types'
require 'test_mud_general'
require 'test_mud_filereader'
require 'test_mud_rulegen'
require 'test_mud_find'

local lu = require('luaunit')
--lu.run('--pattern', 'testGetPath')
--lu.run('--pattern', 'testIPTables')
--lu.run('--pattern', 'TestIPv4Prefix')
lu.run()

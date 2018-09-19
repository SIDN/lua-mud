#!/usr/bin/lua
require 'test_util'
require 'test_yang_types'
require 'test_mud_general'
require 'test_mud_filereader'
require 'test_mud_rulegen'
require 'test_mud_find'
require 'test_mud_acls'

local lu = require('luaunit')
--lu.run('--pattern', 'testGetPath')
--lu.run('--pattern', 'testIPTables')
--lu.run('--pattern', 'TestIPv4Prefix')
--lu.run('--pattern', 'testDraftExample')
--lu.run('--pattern', 'testGetPath3')
--lu.run('--pattern', 'test_order')
lu.run('--pattern', 'testIPTables')
--lu.run('--pattern', 'TestMudACLs')
--lu.run('--pattern', 'testContainerWithChoice')
--lu.run('--pattern', 'TestChoice')
--lu.run('--pattern', 'testMakeRules')
--lu.run()

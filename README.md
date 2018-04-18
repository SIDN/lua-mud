lua-mud
-------

A Manufacturer Usage Description (MUD) library in Lua

See https://tools.ietf.org/html/draft-ietf-opsawg-mud-20

This is a very, very early version; it can parse a subset of MUD specification (draft-20), and find a policy action given IP addresses, domain names and ports.


TODO / Wishlist
---------------

- Support for rest of specification
- Better errors if spec file can't be parsed
- More matcher options
- A way to handle keyword values (such as local-network)
- Firewall rule export system (with one or more modules for specific firewall implementation)
- MUD file generator

PREREQUISITES
-------------

- luarocks (for installation)
- lua-cjson (when not using luarocks)


INSTALLATION
------------

There is a lua rockspec file in the repository, which you can use to install it:

    luarocks make --local


EXAMPLE USES
------------

If installed with --local, do not forget to add ~/.luarocks/bin to your PATH.

    > lua-mud-read examples/example_cloudservice.json 
    MUD URL: https://lighting.example.com/lightbulb2000
    Last update: 2018-03-02T11:20:51+01:00
    Cache validity: 48
    Supported: Yes
    Systeminfo: The BMS Example Lightbulb
    Globally defined acls:
        mud-76100-v6to
            cl0-frdev
        mud-76100-v6fr
            cl0-frdev
    From-device policy:
        mud-76100-v6fr (any)
    To-device policy:
        mud-76100-v6to (any)
    
    > lua-mud-match examples/example_cloudservice.json to test.com 54167 443Match! Actions:
    forwarding: accept
    
    > lua-mud-match examples/example_cloudservice.json from test.com 54167 443
    Match! Actions:
    forwarding: accept

    > lua-mud-match examples/example_cloudservice.json to test.com 54167 80
    [TODO]: direction-initiated
    [Error] unimplemented match type: protocol
    [TODO]: acldns
    No match
    
(that last one shows a number of unimplemented features in matching)


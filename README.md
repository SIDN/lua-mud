# luamud
A Manufacturer Usage Description (MUD) library in Lua

See https://tools.ietf.org/html/draft-ietf-opsawg-mud-20

This is a very, very early version; it can parse a subset of MUD specification (draft-20), and find a policy action given IP addresses, domain names and ports.


TODO / Wishlist:
- Support for rest of specification
- Better errors if spec file can't be parsed
- More matcher options
- A way to handle keyword values (such as local-network)
- Firewall rule export system (with one or more modules for specific firewall implementation)
- MUD file generator

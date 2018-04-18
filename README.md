# luamud
A Manufacturer Usage Description (MUD) library in Lua

See https://tools.ietf.org/html/draft-ietf-opsawg-mud-20

This is a very, very early version; it can parse a subset of MUD specification, and find a policy action given IP addresses, domain names and ports.

It has not been updated to the latest MUD format yet, that will be the first point of order

TODO / Wishlist:
- Update to latest version of Draft Specification
- Support for rest of specification
- Better errors if spec file can't be parsed
- More matcher options
- A way to handle keyword values (such as local-network)
- Firewall rule export system (with one or more modules for specific firewall implementation)
- MUD file generator

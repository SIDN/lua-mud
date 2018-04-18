{
  "ietf-mud:mud": {
    "cache-validity": 48,
    "from-device-policy": {
      "access-lists": {
        "access-list": [
          {
            "name": "mud-76100-v6fr"
          }
        ]
      }
    },
    "is-supported": true,
    "last-update": "2018-03-02T11:20:51+01:00",
    "mud-url": "https://lighting.example.com/lightbulb2000",
    "mud-version": 1,
    "systeminfo": "The BMS Example Lightbulb",
    "to-device-policy": {
      "access-lists": {
        "access-list": [
          {
            "name": "mud-76100-v6to"
          }
        ]
      }
    }
  },
  "ietf-access-control-list:access-lists": {
    "acl": [
      {
        "aces": {
          "ace": [
            {
              "actions": {
                "forwarding": "accept"
              },
              "matches": {
                "ipv6": {
                  "ietf-acldns:src-dnsname": "test.com",
                  "protocol": 6
                },
                "tcp": {
                  "ietf-mud:direction-initiated": "from-device",
                  "source-port": {
                    "operator": "eq",
                    "port": 443
                  }
                }
              },
              "name": "cl0-todev"
            }
          ]
        },
        "name": "mud-76100-v6to",
        "type": "ipv6-acl-type"
      },
      {
        "aces": {
          "ace": [
            {
              "actions": {
                "forwarding": "accept"
              },
              "matches": {
                "ipv6": {
                  "ietf-acldns:dst-dnsname": "test.com",
                  "protocol": 6
                },
                "tcp": {
                  "destination-port": {
                    "operator": "eq",
                    "port": 443
                  },
                  "ietf-mud:direction-initiated": "from-device"
                }
              },
              "name": "cl0-frdev"
            }
          ]
        },
        "name": "mud-76100-v6fr",
        "type": "ipv6-acl-type"
      }
    ]
  }
}

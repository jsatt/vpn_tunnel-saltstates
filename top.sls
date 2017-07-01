base:
    '*':
        - salt
        - users
    'roles:salt-master':
        - match: grain
        - salt.master
    'roles:dns-server':
        - match: grain
        - bind
    'roles:openvpn-server':
        - match: grain
        - openvpn.server
    'roles:openvpn-client':
        - match: grain
        - openvpn.client
    'roles:openvpn-keygen':
        - match: grain
        - openvpn.easy-rsa

# vim: set ft=yaml:

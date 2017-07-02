{% set openvpn = pillar.get('openvpn', {}) -%}
include:
    - openvpn
    - openvpn.easy-rsa

openvpn-server:
    {% if salt['grains.get']('systemd') %}
    service.running:
        - name: openvpn@server.service
    {% else %}
    service.running: []
    {% endif %}

/etc/openvpn/server.conf:
    file.managed:
        - source: salt://openvpn/server.conf
        - template: jinja
        - require:
            - pkg: openvpn
            - pkg: easy-rsa
        - watch_in:
            - service: openvpn-server

{% if openvpn.get('allow_tunnel_traffic', False) -%}
openvpn_nat:
    iptables.append:
        - name: openvpn_tunnel
        - table: nat
        - chain: POSTROUTING
        - source: {{openvpn.get('subnet', '10.8.0.0')}}/{{openvpn.get('subnet_cidr', '24')}}
        - out-interface: {{openvpn.get('tunnel_iface', 'eth0')}}
        - jump: MASQUERADE
    sysctl.present:
        - name: net.ipv4.ip_forward
        - value: 1

openvpn_android_dns_tcp:
    iptables.append:
        - name: android_dns_tcp
        - table: nat
        - chain: PREROUTING
        - in-interface: tun+
        - protocol: tcp
        - dport: 53
        - jump: DNAT
        - to-destination: {{openvpn.get('dns_host', '10.8.0.1')}}

openvpn_android_dns_udp:
    iptables.append:
        - name: android_dns_udp
        - table: nat
        - chain: PREROUTING
        - in-interface: tun+
        - protocol: udp
        - dport: 53
        - jump: DNAT
        - to-destination: {{openvpn.get('dns_host', '10.8.0.1')}}
{% endif -%}

{% if openvpn.get('dynamic_dns', False) -%}
openvpn_learn_address:
    pkg.installed:
        - name: python3-boto3
    file.managed:
        - name: /etc/openvpn/learn_address.py
        - source: salt://openvpn/learn_address.py
        - template: jinja 
        - mode: 755
{% endif %}

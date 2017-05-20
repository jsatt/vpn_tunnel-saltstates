include:
    - openvpn

openvpn-client:
    {% if salt['grains.get']('systemd') %}
    service.running:
        - name: openvpn@client.service
    {% else %}
    service.running:
        - name: openvpn
    {% endif %}

#/etc/openvpn/client.crt:
#    file.managed:
#        - source: salt://vpn-keys/{{grains['id']}}.crt
#        - mode: 600
#        - require:
#            - pkg: openvpn
#        - watch_in:
#            - service: openvpn-client

#/etc/openvpn/client.key:
#    file.managed:
#        - source: salt://vpn-keys/{{grains['id']}}.key
#        - mode: 600
#        - require:
#            - pkg: openvpn
#        - watch_in:
#            - service: openvpn-client

/etc/openvpn/client.conf:
    file.managed:
        - source: salt://openvpn/client.conf
        - template: jinja
        #- require:
            #- file: /etc/openvpn/ca.crt
            #- file: /etc/openvpn/client.crt
            #- file: /etc/openvpn/client.key
        - watch_in:
            - service: openvpn-client

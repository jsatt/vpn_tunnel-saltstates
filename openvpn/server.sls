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

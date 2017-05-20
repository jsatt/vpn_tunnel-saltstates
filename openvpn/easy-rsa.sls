easy-rsa:
    pkg.installed:
        - names:
            - easy-rsa

/usr/share/easy-rsa/vars:
    file.managed:
        - source: salt://openvpn/easy-rsa-vars
        - template: jinja
        - require:
            - pkg: easy-rsa

/usr/share/easy-rsa/keys:
    file.directory:
        - user: root
        - group: root
        - dir_mode: 700
        - require:
            - pkg: easy-rsa

/usr/share/easy-rsa/keys/index.txt:
    file.managed:
        - replace: False
        - user: root
        - group: root
        - mode: 600
        - require:
            - file: /usr/share/easy-rsa/keys

/usr/share/easy-rsa/keys/serial:
    file.managed:
        - contents: "01"
        - replace: False
        - user: root
        - group: root
        - mode: 600
        - require:
            - file: /usr/share/easy-rsa/keys

/usr/share/easy-rsa/keys/ca.crt:
    file.managed:
        - source: salt://vpn-keys/ca.crt
        - user: root
        - group: root
        - mode: 600
        - require:
            - file: /usr/share/easy-rsa/keys

/usr/share/easy-rsa/keys/ca.key:
    file.managed:
        - source: salt://vpn-keys/ca.key
        - user: root
        - group: root
        - mode: 600
        - require:
            - file: /usr/share/easy-rsa/keys


bind:
    pkg.installed:
        - names:
            - bind9
            - bind9utils
            - bind9-doc
    file.managed:
        - name: /etc/bind/named.conf.options
        - source: salt://bind/named.conf.options
        - template: jinja
    service.running:
        - name: bind9
        - watch:
            - file: bind

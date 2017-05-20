include:
    - salt
    - python

install_salt_master:
    cmd.script:
        - source: http://bootstrap.saltstack.org
        - unless: which salt
        - args: "-M git v{{grains['saltversion']}}"

/etc/salt/master:
    file.managed:
        - source: salt://salt/master
        - template: jinja

salt-master:
    service.running:
        - watch:
            - file: /etc/salt/master

wheel:
    group.present

/etc/sudoers:
    file.append:
        - text: |
            %wheel ALL=(ALL) NOPASSWD:ALL

{% for username, user in salt['pillar.get']('users', {}).items() -%}
{% if user.get('absent', False) -%}
user-{{ username }}:
    user.absent:
        - name: {{ username }}
        - purge: True
        - force: True

{% elif grains['id'] in user.get('whitelist', []) or user.get('whitelist') == '*' -%}
{% set home_path = user.get('home_path', '/home/{}'.format(username)) -%}
user-{{ username }}:
    user.present:
        - name: {{ username }}
        {% if user.get('password', '') %}- password: {{ user.password }}{% endif %}
        {% if user.get('groups', []) -%}
        - optional_groups:
            {%- for group in user.groups %}
            - {{ group }}
            {%- endfor %}
        {%- endif %}
        {% if user.get('fullname', '') %}- fullname: {{ user.fullname }}{% endif %}
        - shell: {{ user.get('shell', '/bin/bash') }}
    file.directory:
        - name: {{home_path}}
        - user: {{username}}
        - group: {{username}}
        - mode: 0755

{% if user.get('allowed_sudo', None) %}
user-{{username}}-allowed-sudo:
    file.append:
        - name: /etc/sudoers
        - text: |
            {% for cmd in user['allowed_sudo'] -%}
            {{username}} ALL=(root) {{cmd}}
            {% endfor -%}
{% endif %}

{% if user.get('rsa_priv', None) %}
user-{{username}}-rsa-private-key:
    file.managed:
        - name: {{home_path}}/.ssh/id_rsa
        - user: {{username}}
        - group: {{username}}
        - mode: 0600
        - contents_pillar: users:{{username}}:rsa_priv
        - makedirs: True
        - dir_mode: 0700
{% endif %}

{% if user.get('rsa_pub', None) %}
user-{{username}}-rsa-pub-key:
    file.managed:
        - name: {{home_path}}/.ssh/id_rsa.pub
        - user: {{username}}
        - group: {{username}}
        - mode: 0600
        - contents_pillar: users:{{username}}:rsa_pub
        - makedirs: True
        - dir_mode: 0700
{% endif %}

{% for ssh_auth in user.get('ssh_keys', []) -%}
sshkeys-{{ username }}-{{ssh_auth.key}}:
    ssh_auth.present:
        - user: {{ username }}
        - name: {{ ssh_auth.key }}
        {% if ssh_auth.get('enc') %}- enc: {{ssh_auth.enc}}{% endif %}
        {% if ssh_auth.get('comment') %}- comment: {{ssh_auth.comment}}{% endif %}
{% endfor -%}

{% endif -%}
{% endfor -%}

{% set kops = pillar.get('kops', {}) -%}
include:
    - aws.cli

kubectl:
    file.managed:
        - name: /usr/local/bin/kubectl
        - mode: 775
        # check for latest stable:
        # https://storage.googleapis.com/kubernetes-release/release/stable.txt
        - source: https://storage.googleapis.com/kubernetes-release/release/v1.12.1/bin/linux/amd64/kubectl
        - source_hash: https://storage.googleapis.com/kubernetes-release/release/v1.12.1/bin/linux/amd64/kubectl.sha1

kops:
    file.managed:
        - name: /usr/local/bin/kops
        - mode: 775
        # check for latest release: https://github.com/kubernetes/kops/releases/
        - source: https://github.com/kubernetes/kops/releases/download/1.10.0/kops-linux-amd64
        - source_hash: https://github.com/kubernetes/kops/releases/download/1.10.0/kops-linux-amd64-sha1

kubernetes_support:
    pkg.installed:
        - name: libyaml-dev
    pip.installed:
        - name: "kubernetes"
        - require:
            - pkg: python

kubectl-user:
    user.present:
        - name: kubectl
        - shell: /bin/bash
    file.directory:
        - name: /home/kubectl
        - user: kubectl
        - group: kubectl
        - mode: '0755'

kubectl-private-key:
    file.managed:
        - name: /home/kubectl/.ssh/id_rsa
        - user: kubectl
        - group: kubectl
        - mode: '0600'
        - contents_pillar: kops:keys:private
        - makedirs: True
        - dir_mode: '0700'

kubectl-pub-key:
    file.managed:
        - name: /home/kubectl/.ssh/id_rsa.pub
        - user: kubectl
        - group: kubectl
        - mode: '0600'
        - contents_pillar: kops:keys:public
        - makedirs: True
        - dir_mode: '0700'

{% for cluster in kops.get('clusters', {}).keys() %}
kube-cluster-{{cluster}}:
    file.managed:
        - name: /home/kubectl/clusters/{{cluster}}.yaml
        - source: salt://kube/aws_cluster.yaml
        - template: jinja
        - context:
            cluster_name: {{cluster}}
        - user: kubectl
        - group: kubectl
        - mode: '0664'
        - makedirs: true
        - dir_mode: '0775'
    cmd.run:
        - name: >
            kops replace --force -f /home/kubectl/clusters/{{cluster}}.yaml &&
            kops create secret --name {{cluster}} sshpublickey admin -i /home/kubectl/.ssh/id_rsa.pub &&
            kops update cluster {{cluster}} --yes
        - runas: kubectl
        - env:
            KOPS_STATE_STORE: {{kops.storage}}
        - onchanges:
            - file: kube-cluster-{{cluster}}
{% endfor %}



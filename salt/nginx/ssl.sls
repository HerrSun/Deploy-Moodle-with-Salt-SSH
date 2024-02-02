{% set ssl = pillar['ssl'] %}
{% set moodle = pillar['moodle'] %}

install_acme_client:
  cmd.run:
    - name: 'curl https://get.acme.sh | sh -s email={{ ssl['email'] }}'
    - cwd: '{{ ssl['acme_install_dir'] }}'
    - unless: 'test -d {{ ssl['acme_install_dir'] }}/.acme.sh'

copy_temporary_nginx_config:
  file.managed:
    - name: /etc/nginx/conf.d/{{ moodle['domain'] }}.conf
    - source: salt://nginx/files/nginx_temp.conf
    - template: jinja
    - force: True

nginx_full_restart:
  service.running:
    - name: nginx
    - enable: True
    - full_restart: True

issue_certificate:
  cmd.run:
    - name: '{{ ssl['acme_install_dir'] }}/.acme.sh/acme.sh --issue -d {{ moodle['domain'] }} --nginx --server letsencrypt'
    - unless: "test -f {{ ssl['acme_install_dir'] }}/.acme.sh/{{ moodle['domain'] }}_ecc/{{ moodle['domain'] }}.cer"
    - require:
      - file: copy_temporary_nginx_config

create_certs_directory:
  file.directory:
    - name: {{ ssl['certs_dir'] }}/{{ pillar['moodle']['domain'] }}
    - makedirs: True

install_certs_and_setup_cron:
  cmd.run:
    - name: |
        {{ ssl['acme_install_dir'] }}/.acme.sh/acme.sh --install-cert -d {{ pillar['moodle']['domain'] }} \
        --key-file {{ ssl['certs_dir'] }}/{{ pillar['moodle']['domain'] }}/{{ pillar['moodle']['domain'] }}.key \
        --fullchain-file {{ ssl['certs_dir'] }}/{{ pillar['moodle']['domain'] }}/fullchain.cer \
        --reloadcmd "service nginx force-reload"



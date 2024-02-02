{% set moodle = pillar['moodle'] %}
copy_nginx_config:
  file.managed:
    - name: /etc/nginx/conf.d/{{ moodle['domain'] }}.conf
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - force: True

nginx_restart:
  service.running:
    - name: nginx
    - enable: True
    - full_restart: True
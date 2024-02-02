{% set php_version = pillar['php']['version'] %}
{% set release = salt['cmd.run']('lsb_release -sc') %}

install_prerequisites:
  pkg.installed:
    - pkgs:
      - lsb-release
      - apt-transport-https
      - ca-certificates

add_php_gpg_key:
  cmd.run:
    - name: 'wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg'
    - unless: 'test -f /etc/apt/trusted.gpg.d/php.gpg'

add_php_repository:
  file.managed:
    - name: /etc/apt/sources.list.d/php.list
    - contents: 'deb https://packages.sury.org/php/ {{ release }} main'
    - require:
      - pkg: install_prerequisites
    - watch_in:
      - cmd: update_package_index

update_package_index:
  cmd.run:
    - name: 'apt update'
    - require:
      - file: add_php_repository

install_php8:
  pkg.installed:
    - pkgs:
      - php{{ php_version }}
    - require:
      - cmd: update_package_index

remove_apache2:
  pkg.removed:
    - names:
      - apache2
    - require:
      - pkg: install_php8

install_php_packages:
  pkg.installed:
    - pkgs:
      - php{{ php_version }}
      - php{{ php_version }}-zip
      - php{{ php_version }}-gd
      - php{{ php_version }}-intl
      - php{{ php_version }}-curl
      - php{{ php_version }}-xml
      - php{{ php_version }}-pgsql
      - php{{ php_version }}-fpm
      - php{{ php_version }}-mbstring
      - php{{ php_version }}-yaml
    - require:
      - pkg: install_php8

# enable_pdo_pgsql_extension:
#   file.replace:
#     - name: /etc/php/{{ php_version }}/cli/php.ini
#     - pattern: '^;extension=pdo_pgsql'
#     - repl: 'extension=pdo_pgsql'
#     - require:
#       - pkg: install_php_packages

increase_max_input_vars:
  file.replace:
    - name: /etc/php/{{ php_version }}/cli/php.ini
    - pattern: '^;?max_input_vars = 1000'
    - repl: 'max_input_vars = 5000'
    - require:
      - pkg: install_php_packages
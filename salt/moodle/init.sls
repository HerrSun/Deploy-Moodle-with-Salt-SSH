{% set moodle = pillar['moodle'] %}

install_git:
  pkg.installed:
    - name: git

clone_moodle_repository:
  git.latest:
    - name: git://git.moodle.org/moodle.git
    - target: {{ moodle['path'] }}
    - rev: MOODLE_403_STABLE
    - force_reset: True
    - user: root
    - require:
      - pkg: install_git

copy_moodle_config:
  file.managed:
    - name: {{ moodle['path'] }}/config.php
    - source: salt://moodle/files/config.php
    - template: jinja
    - force: True
    - require:
      - git: clone_moodle_repository

modify_file_permissions:
  file.directory:
    - name: {{ moodle['path'] }}
    - user: root
    - dir_mode: 755
    - recurse:
      - user
      - mode
    - quiet: True

create_moodledata_directory:
  file.directory:
    - name: {{ moodle['datapath'] }}
    - dir_mode: 0777
    - makedirs: True

install_moodle_database:
  cmd.run:
    - name: php install_database.php --adminpass={{ moodle['adminpass'] }} --fullname="{{ moodle['fullname'] }}" --shortname={{ moodle['shortname'] }} --summary="{{ moodle['summary'] }}" --agree-license
    - cwd: {{ moodle['path'] }}/admin/cli
    - require:
      - file: create_moodledata_directory
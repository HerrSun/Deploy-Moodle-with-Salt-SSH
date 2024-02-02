{% set dbname = pillar['postgresql']['dbname'] %}
{% set dbuser = pillar['postgresql']['dbuser'] %}
{% set dbpass = pillar['postgresql']['dbpass'] %}

install_postgresql:
  pkg.installed:
    - name: postgresql

postgresql_service:
  service.running:
    - name: postgresql
    - enable: True
    - require:
      - pkg: install_postgresql

create_moodle_user:
  postgres_user.present:
    - name: {{ dbuser }}
    - password: {{  dbpass}}
    - require:
      - service: postgresql_service

create_moodle_database:
  postgres_database.present:
    - name: {{ dbname }}
    - owner: {{ dbuser }}
    - require:
      - postgres_user: create_moodle_user

grant_privileges_to_moodle_user:
  postgres_privileges.present:
    - name: {{ dbuser }}
    - object_name: {{ dbname }}
    - object_type: database
    - privileges:
      - ALL
    - require:
      - postgres_database: create_moodle_database
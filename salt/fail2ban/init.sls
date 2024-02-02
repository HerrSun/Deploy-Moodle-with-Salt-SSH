update_package_repo:
  cmd.run:
    - name: sudo apt-get update

install_fail2ban:
  pkg.installed:
    - name: fail2ban

configure_fail2ban:
  file.managed:
    - name: /etc/fail2ban/jail.d/sshd.local
    - source: salt://fail2ban/files/sshd.local
    - template: jinja
    - require:
      - pkg: install_fail2ban

fail2ban_service:
  service.running:
    - name: fail2ban
    - enable: True
    - watch:
      - file: configure_fail2ban

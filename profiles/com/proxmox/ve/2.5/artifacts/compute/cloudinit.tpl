#cloud-config
%{ if length(trim(hostname, " ")) > 0 }
hostname: ${hostname}
%{ if length(trim(domainname, " ")) > 0 }
fqdn: ${hostname}.${domainname}
%{ endif }
manage_etc_hosts: true
%{ endif }
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: sudo
    ssh_authorized_keys:
      - ${file(public_key_file)}
  - name: ubicity
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    groups: sudo
    plain_text_passwd: ubicity
    lock_passwd: false
chpasswd:
  expire: false
%{ if length(trim(apt_source, " ")) > 0 }
apt:
  sources:
    userdefined:
      source: ${apt_source}
%{ endif }
package_upgrade: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent

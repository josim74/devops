# Ansible
## inventory.ini or hosts file
```
[webserver]
server1 ansible_host=192.168.1.101
server2 ansible_host= 192.168.1.102

[dbservers]
server3 ansible_host=192.168.1.103

[all:vars]
ansible_user=ubuntu22
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

## Test Inventory
```
# List all inventory
ansible-inventory -i inventory --list

# Ping the servers
ansible all -i inventory -m ping

# Adhoc command
ansible all -i inventory -a "uptime"

# install a package (nginx) to all servers
ansible all -i inventory -b -m apt -a "name=nginx state=present"

# Restart a service
ansible all -i inventory -b -m service -a "name=nginx state=restarted"

# Copy a local file to all host
ansible all -i inventory - m copy -a "src=myfile.txt dest=/tmp/myfile.txt"

# Create a directory
ansible all -i inventory -m file -a "path=/tmp/myfolder state=directory"
```
## Ansible playbook (nginx-playbook.yml)
```
---
- name: Setup web servers
  hosts: webservers
  become: yes
  tasks:
    - name: Ensure nginx is installed
      apt:
        name: nginx
        state: present

    - name: Ensure nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
```
run command: ansible-playbook -i inventory nginx-playbook.yml

## Ansible variables
```
[webserver]
server1 ansible-host=192.168.1.101 http_port=80
server2 ansible-host=192.168.1.102 http_port=8080
```
Access from playbook
```
---
- name: Configure web servers
  hosts: webservers
  become: yes
  tasks:
    - name: Ensure nginx is installed
      apt:
        name: nginx
        state: present

    - name: Update nginx configuration
      lineinfile:
        path: /etc/nginx/sites-available/default
        regexp: '^listen '
        line: 'listen {{ http_port }} default_server;'
      notify: Restart nginx

  handlers:
    - name: Restart nginx
      service:
        name: nginx
        state: restarted
```
Run playbook: ansible-playbook -i inventory nginx-playbook.yml

## Ansible Roles
```
# Create a role structure
ansible-galaxy init myrole

# Use role in playbook
```
---
- name: Playbook to use role
  hosts: webservers
  become: yes
  roles:
    - myrole
```
    


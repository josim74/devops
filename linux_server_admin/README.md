# Linux Administration

## System Information
- `uname -a` – Displays all system information.
- `hostname` – Shows or sets the system's hostname.
- `uptime` – Tells how long the system has been running.
- `top` – Displays real-time system processes and resource usage.
- `htop` – Interactive version of top (must be installed).
- `vmstat` – Reports memory, CPU, and I/O statistics.
- `lscpu` – CPU architecture info.
- `lsblk` – Lists information about block devices.

## User and Group Management

### User Management
- `adduser <username>` – Adds a new user.
- `userdel <username>` – Deletes a user.
- `usermod -aG <group> <user>` – Adds user to a group.
- `passwd <username>` – Changes user password.

### Group Management
- `groupadd <groupname>` – Creates a new group.
- `groupdel <groupname>` – Deletes a group.
- `groups <username>` – Lists groups for a user.

## File and Directory Management
- `ls -l` – Lists files with detailed info.
- `cd <dir>` – Changes directory.
- `mkdir <dir>` – Creates a directory.
- `rm <file/dir>` – Removes file or directory (`-r` for recursive).
- `mv <src> <dest>` – Moves or renames files.
- `cp <src> <dest>` – Copies files or directories.
- `find /path -name <file>` – Finds files in a directory hierarchy.
- `locate <file>` – Searches for files using a database.
  
## Directory Structure
  - `/Root` - The top of the file system hierarchy
  - `/bin` - Binaries and other executable programs (OS level)
  - `/etc` - System configuration files
  - `/home`	- Home directories
  - `/opt` - Optional or third-party software
  - `/tmp`	- Temporary space, typically cleared on reboot
  - `/usr`	- User-related programs
  - `/var`	- Variable data, most notably log files
  - `/boot` -	Files needed to boot the operating system
  - `/cdrom`	- Mount point for CD-ROMs
  - `/cgroup` - Control Groups hierarchy
  - `/dev` - Device files, typically controlled by the operating system and system administrators
  - `/export` - Shared file systems
  - `/lib` -	System Libraries
  - `/lib64` - System Libraries, 64-bit
  - `/lost+found` - Used by the file system to store recovered files after a file system check has been performed
  - `/media`	- Used to mount removable media like CD-ROMs
  - `/mnt`	- Used to mount external file systems
  - `/opt`	- Optional or third-party software
  - `/proc` -	Provides info about running processes
  - `/root`	- The home directory for the root account
  - `/sbin` -	System administration binaries
  - `/selinux` - Used to display information about SELinux
  - `/srv` - Contains data that is served by the system
  - `/srv/www` - Web server files
  - `/srv/ftp` -	Ftp files
  - `/sys` -	Used to display and sometimes configure the devices known to the Linux kernel

## File Permission and Ownership
- `chmod [options] <permissions> <file>` – Changes file permissions.
- `chown <user>:<group> <file>` – Changes file owner and group.
- `ls -l` – Shows current permissions and ownership.

## Process Management
- `ps aux` – Displays all running processes.
- `kill <PID>` – Kills a process by PID.
- `killall <processname>` – Kills all instances of a process.
- `nice` – Launches a process with priority.
- `renice` – Changes priority of a running process.

## Networking Commands
- `ip a` – Displays IP addresses.
- `ifconfig` – Old tool to show or configure interfaces.
- `ping <host>` – Tests connectivity to another host.
- `netstat -tulpn` – Lists ports and services (deprecated).
- `ss -tulpn` – Modern replacement for `netstat`.
- `traceroute <host>` – Shows the route to a host.
- `nslookup <domain>` – Queries DNS.
- `dig <domain>` – Advanced DNS lookup.
- `curl <url>` – Transfers data from/to a server.
- `wget <url>` – Downloads files from the internet.

## Disk and Filesystem Management

### Disk Usage and Info
- `df -h` – Shows disk usage of file systems.
- `du -sh <dir>` – Shows space used by a directory.
- `lsblk` – Lists block devices.
- `fdisk -l` – Lists disk partitions.

### Mounting/Unmounting
- `mount <device> <mountpoint>` – Mounts a file system.
- `umount <mountpoint>` – Unmounts a file system.

## Package Management

### Debian-based (Ubuntu, Debian)
- `apt update` – Refreshes package index.
- `apt upgrade` – Installs updates.
- `apt install <pkg>` – Installs a package.
- `apt remove <pkg>` – Removes a package.

### RHEL-based (CentOS, Fedora)
- `yum update` – Updates packages.
- `yum install <pkg>` – Installs a package.
- `yum remove <pkg>` – Removes a package.
- `dnf` – Successor to `yum` on newer systems.

## System Services
- `systemctl start <service>` – Starts a service.
- `systemctl stop <service>` – Stops a service.
- `systemctl restart <service>` – Restarts a service.
- `systemctl status <service>` – Shows service status.
- `systemctl enable <service>` – Enables service at boot.
- `systemctl disable <service>` – Disables service at boot.
- `journalctl -xe` – Views detailed logs.

## Security and Firewall

### User & File Security
- `sudo` – Run a command as superuser.
- `su -` – Switch to root user.
- `chmod`, `chown` – Control access to files.
- `passwd` – Set/change passwords.

### Firewall (ufw & firewalld)
- `ufw enable` – Enables UFW firewall.
- `ufw allow <port>` – Allows a port.
- `ufw status` – Checks firewall status.
- `firewall-cmd --state` – Checks firewalld state.
- `firewall-cmd --add-port=<port>/tcp --permanent` – Opens port in firewalld.

## Scheduling Tasks
- `crontab -e` – Edits current user's cron jobs.
- `crontab -l` – Lists cron jobs.
- `at <time>` – Schedules a one-time task.
- `systemctl list-timers` – Lists all systemd timers.

## Log Management
- `tail -f /var/log/syslog` – Views system log in real-time.
- `cat /var/log/messages` – Displays general system logs.
- `journalctl` – Views systemd logs.

## Archiving and Compression
- `tar -cvf archive.tar <dir>` – Creates a tar archive.
- `tar -xvf archive.tar` – Extracts tar archive.
- `gzip file` – Compresses file.
- `gunzip file.gz` – Decompresses file.

## System Boot and Shutdown
- `reboot` – Reboots the system.
- `shutdown -h now` – Shuts down immediately.
- `shutdown -r +5` – Reboots in 5 minutes.

## Backup and Restore
- `rsync -av <src> <dest>` – Syncs files/directories.
- `scp <src> <user>@<host>:<dest>` – Secure file copy.
- `dd if=<src> of=<dest>` – Disk clone/image.

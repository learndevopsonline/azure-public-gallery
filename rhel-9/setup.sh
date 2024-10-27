export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/.local/bin:/root/bin"

## Change the identity as RHEL.
rm -f /etc/almalinux-release /etc/system-release
sed -i -e 's/Alma/Redhat/g' -e 's/alma/redhat/g' -e 's/ALMA/REDHAT/' /etc/os-release /etc/system-release-cpe

cd /etc/yum.repos.d
for i in `ls -1`; do
  EFNAME=$i
  sed -i -e 's/name=AlmaLinux/name=RedhatLinux/' $i
  TFNAME=$(echo $i | sed -e 's/almalinux/redhat/')
  mv $EFNAME $TFNAME
done

## Install EPEL - 9
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y

## Install Dependency Packages
dnf install gcc gzip make procps socat tar wget net-tools bind-utils sshpass jq nmap telnet unzip -y

## Check ROOT USER
if [ $(id -u) -ne 0 ]; then
    error "You should be a root/sudo user to perform this script"
    exit 1
fi

## Disabling SELINUX
sed -i -e '/^SELINUX/ c SELINUX=disabled' /etc/selinux/config


## Disable firewall
systemctl disable firewalld &>/dev/null

# Install some base packages
dnf install net-tools bind-utils sshpass jq nmap telnet -y

## Fixing SSH timeouts
sed -i -e '/TCPKeepAlive/ c TCPKeepAlive no' -e '/ClientAliveInterval/ c ClientAliveInterval 10' -e '/ClientAliveCountMax/ c ClientAliveCountMax 240'  /etc/ssh/sshd_config

# User login env setup
cp /tmp/azure-public-gallery/rhel-9/files/ps1.sh /etc/profile.d/ps1.sh
cp /tmp/azure-public-gallery/rhel-9/files/boot-env.sh /etc/profile.d/boot-env.sh
sed -i -e '/^HISTSIZE/ c HISTSIZE=10000' /etc/profile
chmod +x /etc/profile /etc/profile.d/*
sed -i -e '4 i colorscheme desert' /etc/vimrc


# Back-Entry User
useradd vm-user
mkdir -p /home/vm-user/.ssh /root/.ssh
chown vm-user:vm-user /home/vm-user/.ssh
chown root:root /root/.ssh
chmod 700 /home/vm-user/.ssh /root/.ssh
echo "@reboot passwd -u vm-user" >>/var/spool/cron/root
chmod 600 /var/spool/cron/root
echo 'ec2-user ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/vm-user
chattr +i /etc/sudoers.d/vm-user

## Enable SSH Logins
sed -i -e '/^PasswordAuthentication/ c PasswordAuthentication yes' -e '/^PermitRootLogin/ c PermitRootLogin yes' /etc/ssh/sshd_config.d/50-cloud-init.conf
sed -i -e '/PrintMotd/ c PrintMotd yes' /etc/ssh/sshd_config.d/50-redhat.conf
cp /tmp/azure-public-gallery/rhel-9/files/04-ssh-config.conf /etc/ssh/ssh_config.d/04-ssh-config.conf
cp /tmp/azure-public-gallery/rhel-9/files/motd /etc/motd


# Setup Default SSH Keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIfSCB5MtXe54V3lWGBGSxMWPue5CjmSA4ky7E8GUoeZdXxI+df7msJL93PzmtwU3v+O+NLNJJRfmaGpEkgidVXoi6mnYUVCHb1y4zd6QIFEyglGDlvZ4svhHt7T15B13bJC3mTaR2A/xqlvE0/a4XKN1ATYyn6K6CTFJT8I4TIDQmO3PbcNsNFXoO1ef657aqNf0AXC1QWum3HulIt6iJ4s0pQI4hDTmR5EskJxr2K62F4JDOYmVu8bGhFT6ohYbXBCGQtmdp716RnF0Cp1htmxM001wvCSjWLPZuuBjtHXX+op+MJGr0aIqqxdVZ2gw0JeIDfVo7pkSIdTu+p2Yn devops' >/root/.ssh/authorized_keys
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFoOQSSWSX4iJ1F42FODfS7Ct7wxnzRMuKAoTK67Zd5JkjETvroEOcwJHKeRVbjLT8hZuWMz3JdowR25+7W5N23GaBvBq7HbQwec2UGGA6AFAMmijpY1KDZznfBsqVvMY5yT/4XB1RU78dffRuNUs/IeMYnxoh6UO62Zg33JLtJY6waIFNtCFPTN8m4JrsPlt4s6X8E15Jn9Qh9TDNw+R7piDZ/KRDE+paMkflMpptfcNIbK8kzC9/p3DiAMBjmfrReGueI9vrSN66L/BepPTRoUvv9iavKbmu8DEITETlhGnn79V0r0ekXDE6WgZtnTBbbjSFsilNmLw7xjGMS0Bx root@ip-172-31-15-115.ec2.internal' >>/root/.ssh/authorized_keys
cat /tmp/azure-public-gallery/rhel-9/files/id_rsa | base64 --decode > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa

echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIfSCB5MtXe54V3lWGBGSxMWPue5CjmSA4ky7E8GUoeZdXxI+df7msJL93PzmtwU3v+O+NLNJJRfmaGpEkgidVXoi6mnYUVCHb1y4zd6QIFEyglGDlvZ4svhHt7T15B13bJC3mTaR2A/xqlvE0/a4XKN1ATYyn6K6CTFJT8I4TIDQmO3PbcNsNFXoO1ef657aqNf0AXC1QWum3HulIt6iJ4s0pQI4hDTmR5EskJxr2K62F4JDOYmVu8bGhFT6ohYbXBCGQtmdp716RnF0Cp1htmxM001wvCSjWLPZuuBjtHXX+op+MJGr0aIqqxdVZ2gw0JeIDfVo7pkSIdTu+p2Yn devops' >/home/vm-user/.ssh/authorized_keys
chmod 600 /home/vm-user/.ssh/authorized_keys
sed -i -e 's/showfailed//' /etc/pam.d/postlogin


## Install snoopy
mkdir -p /var/log/journal
curl -L -o /tmp/install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh
bash /tmp/install-snoopy.sh stable && rm -f /tmp/install-snoopy.sh

## Disable Golbal GPG Checks by default
sed -i -e '/gpgcheck/ c gpgcheck=0' /etc/dnf/dnf.conf

## Keep the logs clean.
echo ':programname, isequal, "systemd-sysv-generator" /var/log/sysv.log
:programname, isequal, "/usr/sbin/irqbalance" /var/log/irq.log
& stop' >/etc/rsyslog.d/01-sysv.conf

# Commands to /bin
cp /tmp/azure-public-gallery/rhel-9/files/set-hostname /bin/set-prompt
cp /tmp/azure-public-gallery/rhel-9/files/mysql_secure_installation /usr/sbin/mysql_secure_installation
chmod +x /bin/set-prompt /usr/sbin/mysql_secure_installation
sed -i -e '/aws-hostname/ d' -e '$ a r /tmp/aws-hostname' /usr/lib/tmpfiles.d/tmp.conf


# Install Azure CLI
rpm --import https://packages.microsoft.com/keys/microsoft.asc
dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm
dnf install azure-cli -y

# labauto Scripts
curl -s https://raw.githubusercontent.com/learndevopsonline/labautomation/master/labauto >/bin/labauto
chmod +x /bin/labauto

curl -s https://raw.githubusercontent.com/learndevopsonline/labautomation/master/azureauto >/bin/azureauto
chmod +x /bin/azureauto

# FInal Clean up
yum clean all &>/dev/null
rm -rf /var/lib/yum/*  /tmp/*
sed -i -e '/azure_resource-part/ d' /etc/fstab
truncate -s 0 `find /var/log -type f |xargs`
rm -rf /tmp/*


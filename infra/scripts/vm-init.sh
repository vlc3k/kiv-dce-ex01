#
# Create admin user, copy SSH public key and disable root login
#

# Create user
useradd -m -d /home/${INIT_USER} -s /bin/bash ${INIT_USER}
# Set random password
PASSWD=`dd if=/dev/random bs=32 count=1 | base64`
usermod -p ${PASSWD} ${INIT_USER}
# Enable sudo for the user
usermod -aG sudo ${INIT_USER}
echo "${INIT_USER}  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${INIT_USER}

# Setup SSH public key authentication for the user
mkdir -p /home/${INIT_USER}/.ssh
echo "${INIT_PUBKEY}" > /home/${INIT_USER}/.ssh/authorized_keys
chown -R ${INIT_USER}:${INIT_USER} /home/${INIT_USER}/.ssh
chmod go-rwx /home/${INIT_USER}/.ssh/authorized_keys

# Disable password authentication
sed -i 's/PasswordAuthentication .*/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "INIT Users done." >> ${INIT_LOG}

# EOF

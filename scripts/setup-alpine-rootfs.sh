#!/bin/sh
# Ran as part of alpine-make-rootfs, chrooted as the bootstrap thats being built
set -eu

export PATH='/sbin:/usr/sbin:/bin:/usr/bin'
export SHELL='/bin/sh'

# include resolv.conf
echo "nameserver 8.8.8.8 \n \
nameserver 8.8.4.4" >/etc/resolv.conf

# create the user account
adduser -D -g "octoprint" octoprint

export HOME='/home/octoprint'

mkdir -p /home/octoprint/.octoprint/plugins
mkdir -p /home/octoprint/extensions/ttyd

cat <<EOF >/home/octoprint/extensions/ttyd/manifest.json
{
        "title": "Remote web terminal (ttyd)",
        "description": "Uses port 5002; User root / ssh password"
}
EOF

echo "octoprint" >/root/.octoCredentials
cat <<EOF >/home/octoprint/extensions/ttyd/start.sh
#!/bin/sh
ttyd -p 5002 -W --credential root:\$(cat /root/.octoCredentials) bash
EOF

cat <<EOF >/home/octoprint/extensions/ttyd/kill.sh
#!/bin/sh
pkill ttyd
EOF
chmod +x /home/octoprint/extensions/ttyd/*.sh
chmod 755 /home/octoprint/extensions/ttyd/*.sh

cp /mnt/src/comm-fix.py /home/octoprint/

chown -R octoprint /mnt/build/octoprint
chown -R octoprint /home/octoprint/.octoprint

# Build ioctl-hook
gcc -fPIC -c -o /home/octoprint/ioctlHook.o /mnt/build/ioctlHook.c
gcc -shared -o /home/octoprint/ioctl-hook.so /home/octoprint/ioctlHook.o -ldl

# switch to octoprint user
su -s /bin/bash -c "python3 -m venv ~/octoprint-venv" octoprint
su -s /bin/bash -c ". ~/octoprint-venv/bin/activate && cd /mnt/build/octoprint && ls -l && pip3 install ." octoprint
apk --purge del rust cargo

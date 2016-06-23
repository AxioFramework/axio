#!/bin/bash

# This Bash script sets up a new Ubuntu 16.04 LTS (Xenial Xerus) web server.
# ********
# * NOTE * update update_sources_list() when switching Ubuntu versions
# ********
# https://github.com/lojic/sysadmin_tools/blob/master/cloud-setup.bash
#
# Copyright (C) 2011-2016 by Brian J. Adkins

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


#  **********
#  *  NOTE  *
#  **********
#
#  Before running this script, execute the following command to set the locale:
#  sudo update-locale LANG=en_US.UTF-8
#  And then logout/login to "set" the locale. I tried source .bashrc to no avail

#------------------------------------------------------------
# Modify values below here
#------------------------------------------------------------

USERNAME=deploy
APP_NAME=axio
APP_DOMAIN=axioweb.org
NOTIFICATION_EMAIL=  # fail2ban will send emails to this address

# To install postfix, specify a non-empty domain name for POSTFIX_DOMAIN
# e.g. POSTFIX_DOMAIN=yourdomain.com
POSTFIX_DOMAIN=axioweb.org
POSTFIX_NO_TLS=1   # Don't use tls

# To setup ssh keys, specify a full url containing a public key
# e.g. PUBLIC_KEY_URL=http://yourdomain.com/id_rsa.pub
PUBLIC_KEY_URL=http://lojic.com/id_rsa.pub

# Boolean flags 1 => true, 0 => false
BUNDLER=0                # Install bundler gem
CHKROOTKIT=1             # Install chkrootkit root kit checker via apt-get
ECHO_COMMANDS=0          # Echo commands from script
ELASTICSEARCH=0          # Install Elasticsearch
EMACS=1                  # Install Emacs via apt-get
FAIL2BAN=1               # Install fail2ban via apt-get
JAVA=0                   # Install Java JRE
POSTGRES=1               # Install Postgres database via apt-get
RKHUNTER=1               # Install rkhunter root kit checker via apt-get
RSSH=0                   # Install rssh restricted shell
SCREEN=1                 # Install screen via apt-get
SHOREWALL=1              # Install shorewall firewall via apt-get
UNICORN=0                # Install Unicorn

# Prevent prompts during postfix installation
export DEBIAN_FRONTEND=noninteractive

#ELASTICSEARCH_SOURCE=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.3.2/elasticsearch-2.3.2.tar.gz

# To install libyaml, specify a url for source
#LIBYAML_SOURCE=http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz
LIBYAML_SOURCE=

# To install memcached, specify a RAM amount > 0 e.g. 16
#MEMCACHED_RAM=16
MEMCACHED_RAM=0

# To install nginx, specify a url for source
NGINX_SOURCE=http://nginx.org/download/nginx-1.10.0.tar.gz

# To install Ruby, specify a url for source
#RUBY_SOURCE=https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
RUBY_SOURCE=

# To install thttpd, specify a port > 0 e.g. 8000
THTTPD_PORT=0

TIMEZONE=US/Eastern
WWW_DIR=/var/www

#------------------------------------------------------------
# Modify values above here
#------------------------------------------------------------

#------------------------------------------------------------
# Functions
#------------------------------------------------------------

function apt_get_packages_common() {
  display_message "Installing common packages"
  apt-get -y install build-essential dnsutils git-core imagemagick libpcre3-dev \
             libreadline6-dev libssl-dev libxml2-dev locate rsync zlib1g-dev \
             libxslt-dev vim dos2unix
}

function install_libyaml() {
  local libyaml_src=$1

  if [ $libyaml_src ]; then
    display_message "Installing libyaml"
    pushd /usr/local/src
    wget $libyaml_src
    local fname=$(file_name_from_path $libyaml_src)
    tar xzf $fname
    local prefix=${fname%\.tar\.gz}
    cd $prefix
    ./configure
    make
    make install
    popd
  fi
}

function apt_get_packages() {
  display_message "Installing packages"
  apt_get_packages_common

  # Install postfix before rkhunter, or the latter will install exim4
  if [ "$POSTFIX_DOMAIN" ]; then
    install_postfix
  fi

  # rkhunter root kit checker
  if [ "$RKHUNTER" = 1 ]; then
    display_message "Installing rkhunter"
    apt-get -y install rkhunter
    # The rkhunter --update command may have a non-zero return code
    # even when no error occurs. From the man page:
    #
    # An exit code of zero for  this  command  option  means  that  no
    # updates  were  available.  An  exit  code  of  one  means that a
    # download error occurred, and a code of two means that  no  error
    # occurred but updates were available and have been installed.
    set +e
    rkhunter --update
    if [ $? -eq 1 ]; then
      display_message "rkhunter --update failed"
      exit 1
    fi
    set -e
  fi

  if [ "$CHKROOTKIT" = 1 ]; then
    display_message "Installing chkrootkit"
    apt-get -y install chkrootkit
  fi

  if [ "$SHOREWALL" = 1 ]; then
    install_shorewall_firewall
  fi

  if [ "$EMACS" = 1 ]; then
    display_message "Installing emacs"
    apt-get -y install emacs24-nox
  fi

  if [ "$JAVA" = 1 ]; then
    display_message "Installing Java"
    apt-get -y install openjdk-9-jre-headless
  fi

  if [ "$SCREEN" = 1 ]; then
    display_message "Installing screen"
    apt-get -y install screen
  fi

  if [ "$MEMCACHED_RAM" -gt 0 ]; then
    display_message "Installing memcached"
    apt-get -y install memcached
    sed -i.orig -e "/^-m 64/c-m ${MEMCACHED_RAM}" /etc/memcached.conf
  fi

  if [ "$POSTGRES" = 1 ]; then
    install_postgres
  fi

  if [ "$THTTPD_PORT" -gt 0 ]; then
    install_thttpd
  fi

  if [ "$FAIL2BAN" = 1 ]; then
    install_fail2ban
  fi

  if [ "$RSSH" = 1 ]; then
    display_message "Installing rssh"
    apt-get -y install rssh
  fi

  display_message "Clean up unneeded packages"
  apt-get -y autoremove
}

function configure_logrotate() {
  cat >> /etc/logrotate.conf <<'EOF'
/usr/local/nginx/logs/*.log {
    missingok
    notifempty
    sharedscripts
    postrotate
        test ! -f /usr/local/nginx/logs/nginx.pid || kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
    endscript
}
EOF

# Rotate Rails application logs
# /home/deploy/current/log/*.log {
#   daily
#   missingok
#   rotate 7
#   compress
#   delaycompress
#   notifempty
#   copytruncate
# }

}

function configure_nginx() {
  cat > /etc/init.d/nginx <<'EOF'
# Description: Startup script for nginx webserver on Debian. Place in /etc/init.d and
# run 'sudo update-rc.d nginx defaults', or use the appropriate command on your
# distro.
#
# Author:       Ryan Norbauer <ryan.norbauer@gmail.com>
# Modified:     Geoffrey Grosenbach http://topfunky.com

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="nginx daemon"
NAME=nginx
DAEMON=/usr/local/nginx/sbin/$NAME
CONFIGFILE=/usr/local/nginx/conf/nginx.conf
#PIDFILE=/var/run/$NAME.pid
PIDFILE=/usr/local/nginx/logs/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0

d_start() {
  $DAEMON -c $CONFIGFILE || echo -n " already running"
}

d_stop() {
  kill -QUIT `cat $PIDFILE` || echo -n " not running"
}

d_reload() {
  kill -HUP `cat $PIDFILE` || echo -n " can't reload"
}

case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        d_start
        echo "."
        ;;
  stop)
        echo -n "Stopping $DESC: $NAME"
        d_stop
        echo "."
        ;;
  reload)
echo -n "Reloading $DESC configuration..."
d_reload
        echo "reloaded."
  ;;
  restart)
        echo -n "Restarting $DESC: $NAME"
        d_stop
        # One second might not be time enough for a daemon to stop,
        # if this happens, d_start will fail (and dpkg will break if
        # the package is being upgraded). Change the timeout if needed
        # be, or change d_stop to have start-stop-daemon use --retry.
        # Notice that using --retry slows down the shutdown process somewhat.
        sleep 1
        d_start
        echo "."
        ;;
  *)
          echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
          exit 3
        ;;
esac

exit 0
EOF
  chmod 755 /etc/init.d/nginx
  display_message "Setting update-rc.d defaults for nginx"
  update-rc.d nginx defaults
  cp /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/orig.nginx.conf
  cat > /usr/local/nginx/conf/nginx.conf <<EOF
#user  nobody;
worker_processes  4;
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
  include       mime.types;
  default_type  application/octet-stream;

  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for"';

  log_format post_data '\$remote_addr - \$request_body';

  client_max_body_size 30M;

  access_log  logs/access.log  main;

  sendfile        on;
  #tcp_nopush     on;
  #keepalive_timeout  0;
  keepalive_timeout  65;

  gzip  on;
  gzip_proxied any;
  gzip_types application/xml text/xml;

  upstream app_server {
    server localhost:4311;
  }

  server {
    server_name  www.$APP_DOMAIN;
    rewrite ^(.*) http://$APP_DOMAIN\$1 permanent;
  }

  server {
    client_max_body_size 30M;
    listen       80;
    server_name  $APP_DOMAIN;
    root /home/$USERNAME/$APP_NAME/current/public;

    # rewrite for maintenance
    if (-f \$document_root/system/maintenance.html) {
      rewrite  ^(.*)\$  /maintenance.html break;
    }

    # Prefer to serve static files directly from nginx to avoid unnecessary
    # data copies from the application server.
    #
    # try_files directive appeared in in nginx 0.7.27 and has stabilized
    # over time.  Older versions of nginx (e.g. 0.6.x) requires
    # "if (!-f \$request_filename)" which was less efficient:
    # http://bogomips.org/unicorn.git/tree/examples/nginx.conf?id=v3.3.1#n127
    try_files \$uri/index.html \$uri.html \$uri @app;

    location @app {
      # an HTTP header important enough to have its own Wikipedia entry:
      #   http://en.wikipedia.org/wiki/X-Forwarded-For
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

      # enable this if and only if you use HTTPS, this helps Rack
      # set the proper protocol for doing redirects:
      # proxy_set_header X-Forwarded-Proto https;

      # pass the Host: header from the client right along so redirects
      # can be set properly within the Rack application
      proxy_set_header Host \$http_host;

      # we don't want nginx trying to do something clever with
      # redirects, we set the Host: header above already.
      proxy_redirect off;

      # set "proxy_buffering off" *only* for Rainbows! when doing
      # Comet/long-poll/streaming.  It's also safe to set if you're using
      # only serving fast clients with Unicorn + nginx, but not slow
      # clients.  You normally want nginx to buffer responses to slow
      # clients, even with Rails 3.1 streaming because otherwise a slow
      # client can become a bottleneck of Unicorn.
      #
      # The Rack application may also set "X-Accel-Buffering (yes|no)"
      # in the response headers do disable/enable buffering on a
      # per-response basis.
      # proxy_buffering off;

      proxy_pass http://app_server;
    }

    # Rails error pages
    error_page 500 502 503 504 /500.html;
    location = /500.html {
      root /home/$USERNAME/$APP_NAME/current/public;
    }
  }
}
EOF
}

function configure_ntp() {
  echo "/usr/sbin/ntpdate -su time.nist.gov" > /etc/cron.daily/ntpdate
  chmod 755 /etc/cron.daily/ntpdate
}

function configure_timezone() {
  local tz=$1

  if [ $tz ]; then
    echo $tz > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
  fi
}

# Create new user with user:
# create_user username [ public_key_url ]
function create_user() {
  local username=$1
  local pub_key_url=$2
  display_message "Adding new user ${username}:"
  adduser $username

  # Add user to sudoer lsit
  sed -i.orig "\$a$username ALL=ALL" /etc/sudoers

  # Configure command history
  cp /home/${username}/.bashrc /home/${username}/.bashrc.orig
  sed -i -e '/^HISTSIZE/cHISTSIZE=8192' /home/${username}/.bashrc
  sed -i -e '/^HISTFILESIZE/cHISTFILESIZE=8192' /home/${username}/.bashrc
  sed -i -e '/^HISTCONTROL=ignoredups:ignorespace/cHISTCONTROL=ignoredups:ignorespace:erasedups' /home/${username}/.bashrc

  if [ $pub_key_url ]; then
    # Setup ssh keys
    mkdir /home/${username}/.ssh
    chown ${username}:${username} /home/${username}/.ssh
    wget -O /home/${username}/.ssh/authorized_keys $pub_key_url
    chown ${username}:${username} /home/${username}/.ssh/authorized_keys
    chmod 400 /home/${username}/.ssh/authorized_keys
  fi

  if [ $SCREEN ]; then
    # use C-\ instead of C-a to avoid Emacs conflicts
    echo 'escape \034\034' > /home/${username}/.screenrc
    chown ${username}:${username} /home/${username}/.screenrc
    cat >> /home/${username}/.bashrc <<'EOF'
if [ "$TERM" != "screen"  ]; then
  screen -d -R
fi
EOF
  fi

  # Set RAILS_ENV
  cat >> /home/${username}/.bashrc <<'EOF'
RAILS_ENV=production
export RAILS_ENV
EOF
}

function display_message() {
  if [ "$1" ]; then
    echo ' '
    echo '************************************************************'
    echo "$1"
    echo '************************************************************'
    echo ' '
  fi
}

function file_name_from_path() {
  echo ${1##*/}
}

function initialize() {
  # Exit on first error, echo commands
  set -e

  if [ "$ECHO_COMMANDS" = 1 ]; then
      set -x
  fi

  # Set default values
  MEMCACHED_RAM=${MEMCACHED_RAM:-0}
  THTTPD_PORT=${THTTPD_PORT:-0}

  # Elasticsearch requires Java
  if [ "$ELASTICSEARCH" = 1 ]; then
    JAVA=1
  fi
}

function update_sources_list() {
  display_message 'Updating sources list:'
  cat >> /etc/apt/sources.list <<EOF
deb http://us.archive.ubuntu.com/ubuntu/ precise universe
deb-src http://us.archive.ubuntu.com/ubuntu/ precise universe
deb http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
deb-src http://us.archive.ubuntu.com/ubuntu/ precise-updates universe
EOF
}

function install_fail2ban() {
  display_message "Installing fail2ban"
  apt-get -y install fail2ban
  cp /etc/fail2ban//jail.conf /etc/fail2ban/jail.local
  sed -i -e '/^bantime/cbantime = 1800' /etc/fail2ban/jail.local

  if [ "$NOTIFICATION_EMAIL" ]; then
    sed -i -e "/^destemail/cdestemail = ${NOTIFICATION_EMAIL}" /etc/fail2ban/jail.local
  fi

  /etc/init.d/fail2ban restart
}

function install_gems() {
  if [ "$BUNDLER" = 1 ]; then
    display_message "Installing bundler gem"
    gem install --no-rdoc --no-ri bundler
  fi
}

function install_nginx() {
  local nginx_src=$1

  if [ $nginx_src ]; then
    display_message "Installing nginx"
    pushd /usr/local/src
    wget $nginx_src
    local fname=$(file_name_from_path $nginx_src)
    tar xzf $fname
    local prefix=${fname%\.tar\.gz}
    cd $prefix
    ./configure --with-http_ssl_module
    make
    make install
    popd
  configure_nginx
  fi
}

function install_elasticsearch() {
  if [ "$ELASTICSEARCH" = 1 ]; then
      # Download and install the Public Signing Key      
      wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -
      echo "deb https://packages.elastic.co/elasticsearch/2.x/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
      apt-get update && apt-get -y install elasticsearch
      update-rc.d elasticsearch defaults 95 10
  fi
}

function install_postfix() {
  display_message "Installing postfix"
  apt-get -y install postfix
  display_message "Modifying /etc/postfix/main.cf"
  cp /etc/postfix/main.cf /etc/postfix/main.cf.orig
  sed -i -e "/^myhostname/cmyhostname = ${POSTFIX_DOMAIN}" /etc/postfix/main.cf
  sed -i -e "/^mydestination/cmydestination = localhost.localdomain, localhost" /etc/postfix/main.cf
  sed -i -e "/^inet_interfaces/cinet_interfaces = loopback-only" /etc/postfix/main.cf

  if [ "$POSTFIX_NO_TLS" = 1 ]; then
      sed -i -e "/^smtpd_use_tls=yes/csmtpd_use_tls=no" /etc/postfix/main.cf
  fi
}

function install_postgres() {
  display_message "Installing postgresql"
  apt-get -y install libecpg-dev postgresql postgresql-contrib
  su -c psql postgres <<EOF
create role $USERNAME superuser login;
EOF
}

# install_ruby <ruby source url>
function install_ruby() {
  local ruby_src=$1

  if [ $ruby_src ]; then
    display_message "Installing Ruby"
    pushd /usr/local/src
    wget $ruby_src
    local fname=$(file_name_from_path $ruby_src)
    tar xzf $fname
    local prefix=${fname%\.tar\.gz}
    cd $prefix
    ./configure
    make
    make install
    popd
  fi
}

function install_shorewall_firewall() {
  display_message "Installing shorewall firewall"
  apt-get -y install shorewall shorewall-doc

  cat > /etc/shorewall/interfaces <<EOF
#
# Shorewall version 4 - Interfaces File
#
# For information about entries in this file, type "man shorewall-interfaces"
#
# The manpage is also online at
# http://www.shorewall.net/manpages/shorewall-interfaces.html
#
###############################################################################
#ZONE   INTERFACE       BROADCAST       OPTIONS
net     eth0     -          routefilter,tcpflags
#LAST LINE -- ADD YOUR ENTRIES BEFORE THIS ONE -- DO NOT REMOVE
EOF

  cat > /etc/shorewall/policy <<EOF
#SOURCE ZONE   DESTINATION ZONE   POLICY   LOG LEVEL   LIMIT:BURST
\$FW            net                ACCEPT
net            all                DROP     info
all            all                REJECT   info
EOF

  cat > /etc/shorewall/rules <<EOF
#
# Shorewall version 4 - Rules File
#
# For information on the settings in this file, type "man shorewall-rules"
#
# The manpage is also online at
# http://www.shorewall.net/manpages/shorewall-rules.html
#
############################################################################################################################
#ACTION         SOURCE          DEST            PROTO   DEST    SOURCE          ORIGINAL        RATE            USER/   MARK
#                                                       PORT    PORT(S)         DEST            LIMIT           GROUP
#SECTION ESTABLISHED
#SECTION RELATED
SECTION NEW
Web/ACCEPT      net     \$FW
SSH/ACCEPT      net     \$FW
#LAST LINE -- ADD YOUR ENTRIES BEFORE THIS ONE -- DO NOT REMOVE
EOF

  cat > /etc/shorewall/zones <<EOF
#ZONE   TYPE    OPTIONS                 IN                      OUT
#                                       OPTIONS                 OPTIONS
fw      firewall
net     ipv4
EOF

  sed -i.orig -e '/^startup=/cstartup=1' /etc/default/shorewall
}

function install_thttpd() {
  display_message "Installing thttpd"
  apt-get -y install thttpd
  pushd /etc/thttpd
  cp thttpd.conf orig.thttpd.conf
  cat > /etc/thttpd/thttpd.conf <<EOF
port=${THTTPD_PORT}
dir=${WWW_DIR}/thttpd
nochroot
user=www-data
cgipat=**.rb
throttles=/etc/thttpd/throttle.conf
logfile=/var/log/thttpd.log
EOF
  sed -i.orig -e '/^ENABLED=/cENABLED=yes' /etc/default/thttpd
  popd
}

function install_unicorn() {
  if [ "$UNICORN" = 1 ]; then
    display_message "Installing unicorn"
    gem install --no-rdoc --no-ri unicorn
    mkdir /etc/unicorn
    cat > /etc/unicorn/$APP_NAME.conf <<EOF
# Config variables for Rails sites used by other init scripts such as
# thinking-sphinx and unicorn

USER=$USERNAME
RAILS_ROOT=/home/$USERNAME/$APP_NAME/current
RAILS_ENV=production

# to prevent Gemfile not found issues, we explicitly set the Gemfile
BUNDLE_GEMFILE=/home/$USERNAME/$APP_NAME/current/Gemfile
EOF
    cat > /etc/init.d/unicorn <<'EOF'
#!/bin/sh
#
# init.d script for single or multiple unicorn installations. Expects at least one .conf
# file in /etc/unicorn
#
# Modified by jay@gooby.org http://github.com/jaygooby
# based on http://gist.github.com/308216 by http://github.com/mguterl
#
## A sample /etc/unicorn/my_app.conf
##
## RAILS_ENV=production
## RAILS_ROOT=/var/apps/www/my_app/current
#
# This configures a unicorn master for your app at APP_ROOT/my_app/current running in
# production mode. It will read config/unicorn.rb for further set up.
#
# You should ensure different ports or sockets are set in each config/unicorn.rb if
# you are running more than one master concurrently.
#
# If you call this script without any config parameters, it will attempt to run the
# init command for all your unicorn configurations listed in /etc/unicorn/*.conf
#
# /etc/init.d/unicorn start # starts all unicorns
#
# If you specify a particular config, it will only operate on that one
#
# /etc/init.d/unicorn start /etc/unicorn/my_app.conf

set -e

sig () {
  sudo -u $USER sh -c "test -s \"$PID\" && kill -$1 `cat \"$PID\"`"
}

oldsig () {
  sudo -u $USER sh -c "test -s \"$OLD_PID\" && kill -$1 `cat \"$OLD_PID\"`"
}

cmd () {

  case $1 in
    start)
      sig 0 && echo >&2 "Already running" && exit 0
      echo "Starting"
      $CMD
      ;;
    stop)
      sig QUIT && echo "Stopping" && exit 0
      echo >&2 "Not running"
      ;;
    force-stop)
      sig TERM && echo "Forcing a stop" && exit 0
      echo >&2 "Not running"
      ;;
    restart|reload)
      sig USR2 && sleep 5 && oldsig QUIT && echo "Killing old master" `cat $OLD_PID` && exit 0
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      sig USR2 && echo Upgraded && exit 0
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
            sig USR1 && echo rotated logs OK && exit 0
            echo >&2 "Couldn't rotate logs" && exit 1
            ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
      exit 1
      ;;
    esac
}

setup () {

  echo -n "$RAILS_ROOT: "
  cd $RAILS_ROOT || exit 1
  export PID=$RAILS_ROOT/log/unicorn.pid
  export OLD_PID="$PID.oldbin"

  CMD="sudo -u $USER bundle exec /usr/local/bin/unicorn_rails -c config/unicorn.rb -E $RAILS_ENV -D"
}

start_stop () {

  # either run the start/stop/reload/etc command for every config under /etc/unicorn
  # or just do it for a specific one

  # $1 contains the start/stop/etc command
  # $2 if it exists, should be the specific config we want to act on
  if [ $2 ]; then
    . $2
    setup
    cmd $1
  else
    for CONFIG in /etc/unicorn/*.conf; do
      # import the variables
      . $CONFIG
      setup

      # run the start/stop/etc command
      cmd $1
    done
   fi
}

ARGS="$1 $2"
start_stop $ARGS
EOF
  chmod 755 /etc/init.d/unicorn
  display_message "Setting update-rc.d defaults for unicorn"
  update-rc.d unicorn defaults
  fi
}

function epilogue() {
  if [ "$SHOREWALL" = 1 ]; then
    cat <<EOF

Test the firewall via: shorewall safe-start (and verify ssh)
EOF
  fi

  if [ "$RSSH" = 1 ]; then
      cat <<EOF

rssh config file is /etc/rssh.conf
EOF
  fi

  cat <<EOF

Root has been disabled from logging in via ssh.
Use the new user $USERNAME in conjunction with sudo.

Password login has been disabled, you must have your public
key installed in ~/.ssh/authorized_keys

Reboot is recommended to verify processes start properly at boot
EOF
}

# Prevent root login
# Prevent password login
function secure_ssh() {
  display_message 'Securing ssh:'
  cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

  # Ensure root can't ssh in
  sed -i -e '/PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config

  # Don't allow password login if public key has been supplied
  if [ "$PUBLIC_KEY_URL" ]; then
    sed -i -e '/^#PasswordAuthentication yes/cPasswordAuthentication no' /etc/ssh/sshd_config
  fi

  # Restart sshd
  service ssh restart
}

function update_ubuntu() {
  display_message "Updating Ubuntu"
  apt-get -y update
  apt-get -y upgrade
}

#------------------------------------------------------------
# Main
#------------------------------------------------------------

display_message 'Begin cloud-setup.bash:'
initialize
display_message 'initialize complete:'
update_sources_list
display_message 'update_sources_list complete:'
configure_timezone $TIMEZONE
display_message 'Changing root password:'
passwd # Change root passwd
create_user $USERNAME $PUBLIC_KEY_URL
display_message 'user created:'
secure_ssh
display_message 'ssh secured:'
update_ubuntu
display_message 'ubuntu updated:'
apt_get_packages
display_message 'apt-get packages installed:'
install_elasticsearch $ELASTICSEARCH_SOURCE
install_libyaml $LIBYAML_SOURCE
display_message 'libyaml installed:'
install_ruby $RUBY_SOURCE
hash -r  # start using the new Ruby
display_message 'ruby installed:'
install_gems
display_message 'gems installed:'
install_nginx $NGINX_SOURCE
display_message 'nginx installed:'
install_unicorn
display_message 'unicorn installed:'
configure_ntp
display_message 'ntp configured:'
epilogue

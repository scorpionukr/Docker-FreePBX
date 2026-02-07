FROM debian:12-slim

EXPOSE 80 443 4569 5060 10000-20000/udp

RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt -y install build-essential git curl wget libnewt-dev libssl-dev \
  libncurses5-dev subversion libsqlite3-dev libjansson-dev libxml2-dev uuid-dev \
  default-libmysqlclient-dev htop sngrep lame ffmpeg mpg123 
RUN \
  apt -y install git vim curl wget libnewt-dev libssl-dev libncurses5-dev \
  subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev uuid-dev expect
RUN \
  apt -y install build-essential openssh-server apache2 cron \
  mariadb-client bison flex php8.2 php8.2-curl php8.2-cli php8.2-common php8.2-mysql php8.2-gd \
  php8.2-mbstring php8.2-intl php8.2-xml php-pear curl sox libncurses5-dev libssl-dev mpg123 \
  libxml2-dev libnewt-dev sqlite3 libsqlite3-dev pkg-config automake libtool autoconf git \
  unixodbc-dev uuid uuid-dev libasound2-dev libogg-dev libvorbis-dev libicu-dev libcurl4-openssl-dev \
  odbc-mariadb libical-dev libneon27-dev libsrtp2-dev libspandsp-dev sudo subversion libtool-bin \
  python-dev-is-python3 unixodbc vim wget libjansson-dev software-properties-common nodejs npm ipset iptables fail2ban php-soap
RUN \
  wget -O /usr/src/asterisk-20-current.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz && \
  tar xvf /usr/src/asterisk-20-current.tar.gz -C /usr/src/ && \
  cd /usr/src/asterisk-20*/ && \
  contrib/scripts/get_mp3_source.sh && \
  contrib/scripts/install_prereq install && \
  ./configure --libdir=/usr/lib64 --with-pjproject-bundled --with-jansson-bundled && \
  make menuselect.makeopts && \
  menuselect/menuselect --enable app_macro menuselect.makeopts && \
  make menuselect && \
  make && \
  make install && \
  make samples && \
  make config && \
  ldconfig
RUN \
  groupadd asterisk && \
  useradd -r -d /var/lib/asterisk -g asterisk asterisk && \
  usermod -aG audio,dialout asterisk && \
  chown -R asterisk:asterisk /etc/asterisk && \
  chown -R asterisk:asterisk /var/lib/asterisk && \
  chown -R asterisk:asterisk /var/log/asterisk && \
  chown -R asterisk:asterisk /var/spool/asterisk && \
  chown -R asterisk:asterisk /usr/lib64/asterisk  && \
  sed -i 's|#AST_USER|AST_USER|' /etc/default/asterisk && \ 
  sed -i 's|#AST_GROUP|AST_GROUP|' /etc/default/asterisk && \
  sed -i 's|;runuser|runuser|' /etc/asterisk/asterisk.conf && \
  sed -i 's|;rungroup|rungroup|' /etc/asterisk/asterisk.conf && \
  echo "/usr/lib64" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf && \
  ldconfig
RUN \
  sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/8.2/apache2/php.ini && \
  sed -i 's/\(^memory_limit = \).*/\1256M/' /etc/php/8.2/apache2/php.ini && \
  sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf && \
  sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf && \
  a2enmod rewrite && \
  rm /var/www/html/index.html
COPY odbc.ini /etc/odbc.ini
COPY odbcinst.ini /etc/odbcinst.ini
RUN \
  wget -O /usr/local/src/freepbx-17.0-latest-EDGE.tgz http://mirror.freepbx.org/modules/packages/freepbx/freepbx-17.0-latest-EDGE.tgz && \
  tar zxvf /usr/local/src/freepbx-17.0-latest-EDGE.tgz -C /usr/local/src && \
  rm /usr/src/asterisk-20-current.tar.gz && \
  rm /usr/local/src/freepbx-17.0-latest-EDGE.tgz && \
  apt-get clean
ADD run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

VOLUME [ "/var/lib/asterisk", "/etc/asterisk", "/usr/lib64/asterisk", "/var/log/asterisk", "/var/www/html" ]

CMD ["/run-httpd.sh"]
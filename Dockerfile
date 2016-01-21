FROM ubuntu:14.04

MAINTAINER Juan Carlos Coruña <oggers@gmail.com>

ENV REFRESHED_AT 2016-01-21

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y autoconf automake build-essential curl festival git-core libasound2-dev libgnutls-dev libjansson-dev libmyodbc libncurses5-dev libneon27-dev libogg-dev libspandsp-dev libsqlite3-dev libsrtp0-dev libtool libvorbis-dev libxml2-dev pkg-config sqlite sqlite3 subversion unixodbc unixodbc-dev uuid uuid-dev

RUN curl --progress-bar -f -o /tmp/festvox-palpc16k_1.0-1_all.deb -L http://forja.guadalinex.org/frs/download.php/153/festvox-palpc16k_1.0-1_all.deb; \
    curl --progress-bar -f -o /tmp/festvox-sflpc16k_1.0-1_all.deb -L http://forja.guadalinex.org/frs/download.php/154/festvox-sflpc16k_1.0-1_all.deb

RUN dpkg -i /tmp/festvox-palpc16k_1.0-1_all.deb /tmp/festvox-sflpc16k_1.0-1_all.deb && rm -f /tmp/festvox-palpc16k_1.0-1_all.deb /tmp/festvox-sflpc16k_1.0-1_all.deb
# Asterisk
RUN curl --progress-bar -f -o /tmp/asterisk.tar.gz -L http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz

# gunzip asterisk
RUN mkdir /tmp/asterisk
RUN tar -xzf /tmp/asterisk.tar.gz -C /tmp/asterisk --strip-components=1
WORKDIR /tmp/asterisk

# make asterisk.
ENV rebuild_date 2016-01-21
# Configure
RUN ./configure 1> /dev/null
# Remove the native build option
RUN make menuselect.makeopts
# Idea! 
#         menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts
# from: https://wiki.asterisk.org/wiki/display/AST/Building+and+Installing+Asterisk
RUN sed -i "s/BUILD_NATIVE//" menuselect.makeopts
# Continue with a standard make.
RUN make 1> /dev/null
RUN make install 1> /dev/null
RUN make samples 1> /dev/null
RUN ldconfig
WORKDIR /

RUN apt-get purge -y autoconf automake build-essential curl git-core && apt-get autoremove -y && apt-get clean
RUN rm -f /tmp/asterisk.tar.gz; rm -r /tmp/asterisk

# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk

RUN mkdir -p /etc/asterisk
# ADD modules.conf /etc/asterisk/
# ADD iax.conf /etc/asterisk/
# ADD extensions.conf /etc/asterisk/

VOLUME ["/etc/asterisk"]

CMD asterisk -f

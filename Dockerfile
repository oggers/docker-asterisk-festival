FROM ubuntu:14.04

MAINTAINER Juan Carlos Coruña <oggers@gmail.com>

ENV REFRESHED_AT 2016-01-21

ENV DEBIAN_FRONTEND noninteractive
ENV ASTERISKUSER pbxrunner
ENV ASTERISKVER 13.7.0

RUN groupadd -r $ASTERISKUSER && useradd -r -g $ASTERISKUSER $ASTERISKUSER \
             && mkdir /var/lib/asterisk &&chown $ASTERISKUSER.$ASTERISKUSER /var/lib/asterisk \
             && usermod --home /var/lib/asterisk $ASTERISKUSER

RUN apt-get update && apt-get install -y autoconf automake build-essential curl \
    festival git-core libasound2-dev libgnutls-dev libjansson-dev libmyodbc \
    libncurses5-dev libneon27-dev libogg-dev libspandsp-dev libsqlite3-dev \
    libsrtp0-dev libtool libvorbis-dev libxml2-dev libxslt-dev pkg-config sqlite \
    sqlite3 subversion unixodbc unixodbc-dev uuid uuid-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl --progress-bar -f -o /tmp/festvox-palpc16k_1.0-1_all.deb -L \
    http://forja.guadalinex.org/frs/download.php/153/festvox-palpc16k_1.0-1_all.deb; \
    curl --progress-bar -f -o /tmp/festvox-sflpc16k_1.0-1_all.deb -L \
    http://forja.guadalinex.org/frs/download.php/154/festvox-sflpc16k_1.0-1_all.deb

RUN dpkg -i /tmp/festvox-palpc16k_1.0-1_all.deb /tmp/festvox-sflpc16k_1.0-1_all.deb \
    && rm -f /tmp/festvox-palpc16k_1.0-1_all.deb /tmp/festvox-sflpc16k_1.0-1_all.deb

# Asterisk
RUN mkdir /tmp/asterisk && curl --progress-bar -f -o /tmp/asterisk-$ASTERISKVER.tar.gz -L \
    http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-$ASTERISKVER.tar.gz \
    && tar -xzf /tmp/asterisk-$ASTERISKVER.tar.gz -C /tmp/asterisk --strip-components=1

# compilation & instalation
WORKDIR /tmp/asterisk

# make asterisk.
ENV rebuild_date 2016-01-21
# Configure
RUN ./configure
# Remove the native build option
RUN cd menuselect && make menuselect && cd .. && make menuselect-tree
RUN menuselect/menuselect --disable BUILD_NATIVE menuselect/menuselect.makeopts
RUN make && make install && make config
# RUN make samples
WORKDIR /

# Change ownership of asterisk files
RUN chown -R $ASTERISKUSER.$ASTERIKSUSER /var/lib/asterisk \
    && chown -R $ASTERISKUSER.$ASTERIKSUSER /var/spool/asterisk \
    && chown -R $ASTERISKUSER.$ASTERIKSUSER /var/log/asterisk \
    && chown -R $ASTERISKUSER.$ASTERIKSUSER /var/run/asterisk \
    && chown -R $ASTERISKUSER.$ASTERIKSUSER /etc/asterisk

RUN apt-get purge -y autoconf automake build-essential curl git-core && apt-get autoremove -y && apt-get clean
RUN rm -f /tmp/asterisk-$ASTERISKVER.tar.gz; rm -rf /tmp/asterisk

# Update max number of open files.
RUN sed -i -e 's/# MAXFILES=/MAXFILES=/' /usr/sbin/safe_asterisk

# Expose volumes
VOLUME /etc/festival.scm
VOLUME /etc/asterisk
VOLUME /var/lib/asterisk

COPY initconfigfiles/etc/* /etc/asterisk/

# asterisk default port
EXPOSE 5060

WORKDIR /var/lib/asterisk
USER $ASTERISKUSER
CMD ["/usr/sbin/asterisk", "-f"]

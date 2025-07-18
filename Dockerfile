FROM ubuntu:18.04

RUN dpkg --add-architecture i386 && \
    apt-get update

RUN apt-get install -y \
    alien \
    ant \
    bison \
    cmake \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    libaio1:i386 \
    libboost-dev \
    libboost-program-options-dev \
    libcurl4-gnutls-dev:i386 \
    libncurses5-dev:i386 \
    libsqlite3-dev \
    libxml2-dev:i386 \
    openjdk-11-jdk:i386 \
    psmisc \
    supervisor \
    wget

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN wget https://github.com/SWG-Source/releases/releases/download/instantclients/oracle-instantclient18.3-basiclite-18.3.0.0.0-1.i386.rpm
RUN wget https://github.com/SWG-Source/releases/releases/download/instantclients/oracle-instantclient18.3-devel-18.3.0.0.0-1.i386.rpm
RUN wget https://github.com/SWG-Source/releases/releases/download/instantclients/oracle-instantclient18.3-sqlplus-18.3.0.0.0-1.i386.rpm

RUN alien -i --target=amd64 oracle-instantclient18.3-basiclite-18.3.0.0.0-1.i386.rpm
RUN alien -i --target=amd64 oracle-instantclient18.3-devel-18.3.0.0.0-1.i386.rpm
RUN alien -i --target=amd64 oracle-instantclient18.3-sqlplus-18.3.0.0.0-1.i386.rpm

RUN rm -f oracle-instantclient18.3-*-18.3.0.0.0-1.i386.rpm

ENV ORACLE_HOME=/usr/lib/oracle/18.3/client
ENV LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client/lib:/usr/include/oracle/18.3/client
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-i386

RUN git clone https://github.com/SWG-Source/swg-main.git /swg-main
WORKDIR /swg-main
RUN ant git_update_submods

RUN echo "db_service = FREEPDB1" > local.properties && \
    echo "dbip = oracle" >> local.properties

CMD ["/usr/bin/supervisord", "-n"]
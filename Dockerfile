FROM ubuntu:14.04

ENV SRC=https://github.com/pachterlab/kallisto/releases/download/v0.42.5/kallisto_linux-v0.42.5.tar.gz ZIP=kallisto_linux-v0.42.5.tar.gz DST=/bin
ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN     echo 'search example.com' > /etc/resolv.conf && \
        echo 'nameserver 149.155.208.92' >> /etc/resolv.conf && \
        echo 'nameserver 149.155.208.93' >> /etc/resolv.conf && \
        echo 'nameserver 149.155.208.91' >> /etc/resolv.conf && \
        echo 'nameserver 8.8.8.8' >> /etc/resolv.conf && \
        echo 'nameserver 8.8.4.4' >> /etc/resolv.conf && \
        apt-get -y update && apt-get -yy install wget && \
        cd $DST && \
        wget $SRC && \
        tar -xvf $ZIP && rm $ZIP && cp $DST/kallisto_linux-v0.42.5/kallisto .
      
WORKDIR /data/


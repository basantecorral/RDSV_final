FROM ubuntu:bionic
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get clean
RUN apt-get update \
    && apt-get install -y apt-utils \
    net-tools \
    vim \
    arpwatch
RUN touch /var/lib/arpwatch/arp.dat
CMD ["bash", "cmd.sh"]

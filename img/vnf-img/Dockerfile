FROM ubuntu:bionic
#To run dpkg (behind other tools like Apt) without interactive dialogue
ARG DEBIAN_FRONTEND=noninteractive
# install required packages
RUN apt-get clean
RUN apt-get update \
    && apt-get install -y  git \
    apt-utils \
    net-tools \
    aptitude \
    build-essential \
    python-setuptools \
    python-dev \
    python-pip \
    software-properties-common \
    ansible \
    curl \
    iptables \
    iputils-ping \
    sudo \
    nano \
    bridge-utils \
    isc-dhcp-server \
    tcpdump \
    openvswitch-switch \
    iperf3 \
    vim \
    ryu-bin \
    iproute2


COPY dhcpd.conf /etc/dhcp/dhcpd.conf
COPY isc-dhcp-server /etc/default/isc-dhcp-server

#Install isc-dhcp-server
#RUN apt-get update
#RUN apt-get install isc-dhcp-server 
#RUN apt-get update
#RUN apt-get install isc-dhcp-relay

#simple_switch_13.py localizado en ./usr/lib/python3/dist-packages/ryu/app/simple_switch_13.py => encontrado con find -iname simple_switch_13.py
RUN sed '/OFPFlowMod(/,/)/s/)/, table_id=1)/' /usr/lib/python3/dist-packages/ryu/app/simple_switch_13.py > qos_simple_switch_13.py

# open ports
# IPERF3
EXPOSE 5201
# IPERF3
EXPOSE 3000
# IPERF3
EXPOSE 7000

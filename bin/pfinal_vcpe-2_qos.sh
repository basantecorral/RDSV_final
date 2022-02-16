#!/bin/bash

# Configuracion QOS vcpe-1


VNF1="mn.dc1_vcpe-2-1-ubuntu-1"
RYUIP=`sudo docker exec -it mn.dc1_vcpe-2-1-ubuntu-1 ifconfig | grep 10.255.0 | awk '{print $2}'`
echo "----------Iniciando configuracion de Qos para VCPE-2----------"

#Obtencion de direcciones IP de h11 y h12
IP21=`sudo vnx -f ../vnx/nfv3_home_lxc_ubuntu64.xml -M h11 --exe-cli ifconfig | grep 192.168.255 | awk '{print $2}'`
IP22=`sudo vnx -f ../vnx/nfv3_home_lxc_ubuntu64.xml -M h12 --exe-cli ifconfig | grep 192.168.255 | awk '{print $2}'`

#Configuracion del controlador Ryu en vclass
echo "Configurando controlador Ryu"
sudo docker exec -it $VNF1 ovs-vsctl set bridge br0 protocols=OpenFlow10,OpenFlow12,OpenFlow13
sudo docker exec -it $VNF1 ovs-vsctl set-fail-mode br0 secure
sudo docker exec -it $VNF1 ovs-vsctl set bridge br0 other-config:datapath-id=0000000000000001
sudo docker exec -it $VNF1 ovs-vsctl set-controller br0 tcp:$RYUIP:6633
sudo docker exec -it $VNF1 ovs-vsctl set-manager ptcp:6632
sudo docker exec -d $VNF1 ryu-manager ryu.app.rest_qos ryu.app.rest_conf_switch ./qos_simple_switch_13.py
sleep 20
echo "Configuracion terminada"

#Configuracion reglas Qos
echo "Configuracion de reglas QoS"
sudo docker exec -it $VNF1 curl -X PUT -d '"tcp:127.0.0.1:6632"' http://$RYUIP:8080/v1.0/conf/switches/0000000000000001/ovsdb_addr
sleep 15
echo "Confiracion de cola:"
sudo docker exec -it $VNF1 curl -X POST -d '{"port_name": "vxlan1", "type": "linux-htb", "max_rate": "12000000", "queues": [{"min_rate": "8000000"}, {"max_rate": "4000000"}]}' http://$RYUIP:8080/qos/queue/0000000000000001
sleep 15
echo "Configuracion de rule 1:"
sudo docker exec -it $VNF1 curl -X POST -d '{"match": {"nw_dst": "'$IP21'"}, "actions":{"queue": "0"}}' http://$RYUIP:8080/qos/rules/0000000000000001
sleep 15
echo "Configuracion de rule 2:"
sudo docker exec -it $VNF1 curl -X POST -d '{"match": {"nw_dst": "'$IP22'"}, "actions":{"queue": "1"}}' http://$RYUIP:8080/qos/rules/0000000000000001
sleep 5
echo "Get colas:"
sudo docker exec -it $VNF1 curl -X GET http://$RYUIP:8080/qos/rules/0000000000000001
sleep 5
echo "Get rules:"
sudo docker exec -it $VNF1 curl -X GET http://$RYUIP:8080/qos/rules/0000000000000001

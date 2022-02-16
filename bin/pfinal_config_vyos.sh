#!/bin/bash

echo "Configurando router VyOS..."

USAGE="
Usage:

vcpe_start <vcpe_name> <vcpe_private_ip> <vcpe_public_ip>
    being:
        <vcpe_name>: the name of the network service instance in OSM
        <vcpe_private_ip>: the private ip address for the vcpe
        <vcpe_public_ip>: the public ip address for the vcpe (10.2.2.0/24)
"

if [[ $# -ne 3 ]]; then
        echo ""
    echo "ERROR: incorrect number of parameters"
    echo "$USAGE"
    exit 1
fi

VCPEPRIVIP="$2"
VCPEPUBIP="$3"

VNF1="mn.dc1_$1-1-ubuntu-1"
VNF2="mn.dc1_$1-2-VyOS-1"

#Obtenemos direcciones MAC e IP para VNF1 y VNF2
ETH11=`sudo docker exec -it $VNF1 ifconfig | grep eth1 | awk '{print $1}'`
ETH21=`sudo docker exec -it $VNF2 ifconfig | grep eth1 | awk '{print $1}'`
IP11=`sudo docker exec -it $VNF1 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`
IP21=`sudo docker exec -it $VNF2 hostname -I | awk '{printf "%s\n", $1}{print $2}' | grep 192.168.100`

# Para solucionar un error que aparece en la configuracion de DHCP, debemos modificar una linea en el fichero usr/libexec/vyos/conf_mode/dhcp_server.py .
# Copiamos en el contenedor el fichero con la linea modificada
sudo docker cp dhcp_server.py $VNF2:usr/libexec/vyos/conf_mode/
#Configuracion de VyOS:
sudo docker exec -ti $VNF2 /bin/bash -c "
source /opt/vyatta/etc/functions/script-template

configure

# Configuracion de tunel vxlan entre vclass y vcpe
set interfaces vxlan vxlan0 address $VCPEPRIVIP/24
set interfaces vxlan vxlan0 description 'VLAN vxlan0 para la practica final RDSV'
set interfaces vxlan vxlan0 remote $IP11
set interfaces vxlan vxlan0 vni 1
#8472 puerto UDP por defecto
set interfaces vxlan vxlan0 port 8472
#1400 de mtu porque si miramos el fichero de descripcion de vnx es lo que tienen configurados los host
set interfaces vxlan vxlan0 mtu 1400

# Configuracion DHCP
#This says that this device is the only DHCP server for this network
set service dhcp-server shared-network-name vxlan0 authoritative
set service dhcp-server shared-network-name vxlan0 subnet 192.168.255.0/24 default-router $VCPEPRIVIP
set service dhcp-server shared-network-name vxlan0 subnet 192.168.255.0/24 dns-server $VCPEPRIVIP
set service dhcp-server shared-network-name vxlan0 subnet 192.168.255.0/24 domain-name 'net1.net'
#Lease asigna un tiempo (en segundos) para las direcciones IP. 86400 es el default que corresponde a un dia
set service dhcp-server shared-network-name vxlan0 subnet 192.168.255.0/24 lease '86400'
#En este parte se asigna el rango de direcciones IP para DHCP
set service dhcp-server shared-network-name vxlan0 subnet 192.168.255.0/24 range 0 start '192.168.255.10'
set service dhcp-server shared-network-name vxlan0 subnet 192.168.255.0/24 range 0 stop '192.168.255.50'


# Configuracion ruta hacia el exterior. Segun viene en las recomendaciones de la practica, desactivamos interfaz eth0
set interfaces ethernet eth0 disable
set interfaces ethernet eth2 address $VCPEPUBIP/24
set protocols static route 0.0.0.0/0 next-hop 10.2.3.254 distance '1'

# Canfiguracion del NAT
set nat source rule 100 outbound-interface eth2
set nat source rule 100 source address 192.168.255.0/24
#The translation address must be set to one of the available addresses on the configured outbound-interface or it must be set to masquerade which will use the primary IP address of the outbound-interface as its translation address.
set nat source rule 100 translation address 'masquerade'

commit
save
exit
"

echo "Configuracion del router VyOS finalizada"

#!/bin/bash

echo "Parando el escenario de la practica final..."

#Paso 1: Parar redes VNX
sudo vnx -f ../vnx/nfv3_home_lxc_ubuntu64.xml --destroy
sudo vnx -f ../vnx/nfv3_server_lxc_ubuntu64.xml --destroy
echo "Redes VNX eliminadas"

#Paso 2: Eliminar instancia NS
./vcpe_destroy.sh vcpe-1
sleep 5
echo "Instancia vcpe-1 eliminada"
./vcpe_destroy.sh vcpe-2
sleep 5
echo "Instancia vcpe-2 eliminada"

#Paso 3: Eliminar ExtNet y AccessNet
sudo ovs-vsctl --if-exists del-br ExtNet
sudo ovs-vsctl --if-exists del-br AccessNet

echo "Escenario de la practica final eliminado"

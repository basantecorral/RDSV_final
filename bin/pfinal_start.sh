#!/bin/bash

echo "Inicializando el escenario de la practica final..."

#Paso 1: Creacion de AccessNet y ExtNet
sudo ovs-vsctl --if-exists del-br AccessNet
sudo ovs-vsctl --if-exists del-br ExtNet
sudo ovs-vsctl add-br AccessNet
sudo ovs-vsctl add-br ExtNet
echo "AccessNet y ExtNet creados"

#Paso 2: Crear vnf-img e importar imagen vyos
sudo docker build -t vnf-img ../img/vnf-img
sudo docker image load -i ../img/vnf-vyos/vyos-rolling-1.3.tar.gz
echo "Imagen vyos y VNF creadas"

#Paso 3: Instalar descriptores de VNF y NS
osm vnfd-create ../pck/vnf-vcpe.tar.gz
osm vnfd-create ../pck/vnf-vclass.tar.gz
osm nsd-create ../pck/ns-vcpe.tar.gz
echo "Descriptores de VNFs y NS cargados correctamente en OSM"

#Paso 4: Iniciar instancia NS
osm ns-create --ns_name "vcpe-1" --nsd_name vCPE --vim_account emu-vim
sleep 5
echo "----------NS vcpe-1 inicializada----------"
osm ns-create --ns_name "vcpe-2" --nsd_name vCPE --vim_account emu-vim
sleep 5
echo "----------NS vcpe-2 inicializada----------"

#Paso 5: Creacion de las redes vnx residencial y exterior
sudo vnx -f ../vnx/nfv3_home_lxc_ubuntu64.xml -t
sudo vnx -f ../vnx/nfv3_server_lxc_ubuntu64.xml -t
echo "Escenariols VNX creados"

echo "-------EL ESCENARIO DE LA PRACTICA FINAL ESTA LISTO------"
echo "Autores: ALVARO BASANTE CORRAL, ORLANDO LEÓN MORALES y JOSE CARLOS INFANTE DURAN"

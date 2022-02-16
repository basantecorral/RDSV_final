#!/bin/bash

#Script que llama a pfinal_vnf_config para la configuracion de los tuneles de VNF class
echo "--------CONFIGURACION PARA VCPE-1------------"
./pfinal_vnf_config.sh vcpe-1 10.255.0.1 10.255.0.2
echo "--------CONFIGURACION PARA VCPE-2------------"
./pfinal_vnf_config.sh vcpe-2 10.255.0.3 10.255.0.4

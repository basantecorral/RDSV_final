#!/bin/bash

#Este script llama a pfinal_config_vyos y configura el NFV en vcpe-1 y vcpe-2 asignandole una direccion ip privada 192.168.255.1 y una direccion ip publica 10.2.3.1 y 10.2.3.2
echo "----------CONFIGURACION VYOS VCPE-1----------"
./pfinal_config_vyos.sh vcpe-1 192.168.255.1 10.2.3.1
echo "----------CIBFIGURACION VYOS VCPE-2----------"
./pfinal_config_vyos.sh vcpe-2 192.168.255.1 10.2.3.2

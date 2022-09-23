#!/bin/bash

# Autor: José Henrique Nunes Bernardino
# Contact: josehenrique9870@hotmail.com
# Since: 23-09-2022
# Version: v1.0


# Variáveis utilizadas nas configurações do sistema
DOCKERGPG="https://download.docker.com/linux/ubuntu/gpg"
DOCKERKEY="0EBFCD88"
DOCKERREP="deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)

# Download do Docker Compose
DOCKERCOMPOSE="https://github.com/docker/compose/releases/download/v2.11.1/docker-compose-linux-x86_64"
DOCKERDEP="dockercommunity"

DOCKERINSTALLDEP="apt-transport-https ca-certificates curl software-properties-common \
linux-image-generic linux-image-extra-virtual python3-dev python3-pip libffi-dev gcc \
libc-dev cargo make"

# Variável de instalação do Docker Community CE.
DOCKERINSTALL="docker-ce cgroup-lite"

# Porta padrão do Portainer.io
PORTPORTAINER="9000"

# Configuração da variável de log
LOG=$ARQUIVOLOG

#
# Verificação do usuário e a Distribuição do sistema
#

clear
if [ "$USUARIO" == '0' ] && [ "$UBUNTU" == "20.04" ]
    then
        echo -e "Usuário Root               -   \033[01;32m OK \033[01;37m"
        echo -e "Distribuição >= 20.04.x    -   \033[01;32m OK \033[01;37m"
        sleep 3
elif [ "$UBUNTU" == "20.04" ]
    then
        echo -e "Usuário Root               -   \033[01;31m Fail \033[01;37m"
        echo -e "Distribuição >= 20.04.x    -   \033[01;32m OK \033[01;37m"
        exit 1
elif [ "$USUARIO" == '0' ]
    then
        echo -e "Usuário Root               -   \033[01;32m OK \033[01;37m"
        echo -e "Distribuição >= 20.04.x    -   \033[01;31m Fail \033[01;37m"
        exit 1
    else
        echo -e "Usuário Root               -   \033[01;31m Fail \033[01;37m"
        echo -e "Distribuição >= 20.04.x    -   \033[01;31m Fail \033[01;37m"
        exit 1
fi

#
# Verificação da porta 9000
#
if [ "$(nc -vz 127.0.0.1 $PORTPORTAINER &> /dev/null ; echo $?)" == "0" ]
	then
        echo -e "A porta $PORTPORTAINER ja está sendo utilizada."
        sleep 2
        exit 1
    else
        echo -e "A porta $PORTPORTAINER não está sendo utilizada."
        sleep 2
fi


#
# Verificação de dependências do Docker Community
#

echo -n "Verificação de dependencias do Docker Community, aguarde..."
    for name in $DOCKERDEP
    do
        [[ $(dpkg -s $name 2> /dev/null) ]] || {
            echo -en "\n \nO software: $name precisa ser instalado. \nUse o comando 'apt install $name'\n";
            deps=1;
            }
    done
        [[ $deps -ne 1 ]] && echo "Dependências:    \033[01;32m OK \033[01;37m" || {
            echo -en "\nInstale as dependências acima e execute novamente.\n";
            exit 1;
            }
        sleep 3



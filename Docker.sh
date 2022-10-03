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
DOCKERDEP="bind9"

DOCKERINSTALLDEP="apt-transport-https ca-certificates curl software-properties-common \
linux-image-generic linux-image-extra-virtual python3-dev python3-pip libffi-dev gcc \
libc-dev cargo make"

# Variável de instalação do Docker Community CE.
DOCKERINSTALL="docker-ce cgroup-lite docker-ce-cli"

# Porta padrão do Portainer.io
PORTPORTAINER="9000"

# Configuração da variável de log
LOG=("/var/log/dockerinstall")

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
        [[ $deps -ne 1 ]] && echo -e "Dependências:    -   \033[01;32m OK \033[01;37m" || {
            echo -en "\nInstale as dependências acima e execute novamente.\n";
            exit 1;
            }
        sleep 3


#
# Instalação do Bind9 e do Portainer.io
#

echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n" &>> $LOG

echo 

echo -e "Após instalação do Portainer.io acesse: http://$(hostname -d | cut -d ' ' -f1):9000/\n"
sleep 3

#
# Atualização de pacotes
#

echo -e "Atualizando todo o sistema operacional, aguarde..."

echo 

    apt-get update && apt-get upgrade && apt-get dist-upgrade && apt-get full-upgrade -y &>> $LOG

echo -e "Sistema atualizado com sucesso!!!, continuando...\n"


echo -e "Removendo todos os software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso!!!, continuando...\n"

#
# Instalação de pacotes necessarios para o Docker
#

echo -e "Incio de instalação de pacotes necessarios, aguarde..."

echo

apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo -e "Adicionando a Chave GPG do Docker, aguarde..."
	curl -fsSL $DOCKERGPG | apt-key add - &>> $LOG
echo -e "Chave adicionada com sucesso!!!, continuando...\n"


echo -e "Adicionando o repositório do Docker, aguarde..."
	add-apt-repository "$DOCKERREP" &>> $LOG
echo -e "Repositório adicionado com sucesso!!!, continuando...\n"
sleep 1


echo -e "Atualizando list APT, aguarde..."

echo 

    apt-get update -y &>> $LOG

echo -e "Sistema atualizado com sucesso!!!, continuando...\n"


echo -e "Instalando o Docker CE, aguarde..."
	apt  install $DOCKERINSTALL -y &>> $LOG
echo -e "Docker instalado com sucesso!!!, continuando...\n"
sleep 2

echo -e "Instalando o Docker Compose, aguarde..."
    wget -O docker-compose $DOCKERCOMPOSE &>> $LOG
    mv docker-compose /usr/local/bin/ &>> $LOG
    chmod +x /usr/local/bin/ &>> $LOG
    docker-compose --version &>> $LOG
echo -e "Docker Compose instalado com sucesso. \n"
sleep 2

echo -e "Usuario Root adicionado no grupo do Docker."
    usermod -aG docker $USER &>> $LOG
sleep 1

echo -e "Habilitando inicialização do Docker "
    systemctl enable docker $>> $LOG
    systemctl start docker $>> $LOG
sleep 1



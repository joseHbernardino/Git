#!/bin/bash

# Autor: José Henrique Nunes Bernardino
# Contact: josehenrique9870@hotmail.com
# Since: 23-09-2022
# Version: v1.5


# Variáveis utilizadas nas configurações do sistema
DOCKERGPG="https://download.docker.com/linux/ubuntu/gpg"
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


echo -e "Início do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n\n" &>> $LOG

#
# Verificação de dependências do Docker Community
#

echo -n "Verificação de dependencias do Docker Community..."
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



echo -e "Atualizando o sistema.\n"

    apt-get update && apt-get upgrade -y  &>> $LOG

echo -e "Sistema atualizado com sucesso.\n"


echo -e "Removendo todos os software desnecessários."
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso.\n"


#
# Instalação de pacotes necessarios para o Docker
#


echo -e "Incio de instalação de pacotes necessarios..."
	apt-get install $DOCKERINSTALLDEP -y &>> $LOG
echo -e "Instalação das dependências feita com sucesso.\n"
sleep 2


echo -e "Adicionando a Chave GPG do Docker..."
	curl -fsSL $DOCKERGPG | apt-key add - &>> $LOG
echo -e "Chave adicionada com sucesso.\n"


echo -e "Adicionando o repositório do Docker..."
	add-apt-repository "$DOCKERREP" &>> $LOG
echo -e "Repositório adicionado com sucesso.\n"
sleep 1


echo -e "Instalando o Docker CE..."
	apt-get  install $DOCKERINSTALL -y &>> $LOG
echo -e "Docker instalado com sucesso.\n"
sleep 2


echo -e "Instalando o Docker Compose..."
    wget -O docker-compose $DOCKERCOMPOSE &>> $LOG
    mv docker-compose /usr/local/bin/ &>> $LOG
    chmod +x /usr/local/bin/ &>> $LOG
    docker-compose --version &>> $LOG
echo -e "Docker Compose instalado com sucesso. \n"
sleep 2

echo -e "Usuario Root adicionado no grupo do Docker."
    usermod -aG docker $USER &>> $LOG
sleep 1

echo -e "Habilitando inicialização do Docker \n"
    systemctl enable docker &>> $LOG
    /etc/init.d/docker start docker &>> $LOG
sleep 1


echo -e "\n------------------------------"
echo -e "| Configuração do Portainer.io|"
echo -e "------------------------------\n"



docker volume create portainer_data &>> $LOG
echo -e "Volume do Portainer.io                -   \033[01;32m OK \033[01;37m"
sleep 1

docker run --name portainer -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer &>> $LOG
echo -e "Criação do Container                  -   \033[01;32m OK \033[01;37m"
sleep 2



echo -e "Criação do Serviço de Inicialização"
    systemctl daemon-reload &>> $LOG
    systemctl enable portainer &>> $LOG
    systemctl start portainer &>> $LOG
sleep 2

echo -e "Fim do script $0 em: $(date +%d/%m/%Y-"("%H:%M")")\n"
echo -e "Instalação concluida com sucesso press <Enter>"


echo -e "Após instalação do Portainer.io acesse: http://localhost:9000/\n"
sleep 3
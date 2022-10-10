#!/bin/bash

# Autor: José Henrique Nunes Bernardino
# Contact: josehenrique9870@hotmail.com
# Since: 14-09-2022
# Version: v2.0








USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)


MYSQLINSTALL="mysql-server mysql-client mysql-common"
APACHEINSTALL="apache2"


# Configuração da variável de log
LOG=("/var/log/mysqlinstall")
LOG2=("/var/log/apacheinstall")




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


echo -e "Atualizando o sistema.\n"

    apt-get update && apt-get upgrade -y  &>> $LOG

echo -e "Sistema atualizado com sucesso.\n"



echo -e "Removendo todos os software desnecessários."
	apt -y autoremove &>> $LOG
	apt -y autoclean &>> $LOG
echo -e "Software removidos com sucesso.\n"


#
# Instalação de pacotes necessarios para o Mysql
#

clear

echo -e "Incio de instalação de pacotes necessarios do MySQL..."
	apt-get install $MYSQLINSTALL -y &>> $LOG
echo -e "Instalação das dependências feita com sucesso.\n"
sleep 2
echo -e "Iniciando do MySQL\n"
    /etc/init.d/mysql start

clear


echo -e "Incio de instalação de pacotes necessarios do Apache2..."
	apt-get install $APACHEINSTALL -y &>> $LOG2
echo -e "Instalação das dependências feita com sucesso.\n"
sleep 2
echo -e "Iniciando do Apache2\n"
    /etc/init.d/apache2 start


#Politica de segurança do MySQL

#sudo mysql_secure_installation

1. Connecting to MySQL using a blank password: 
#Please set the password for root here.
2. Enter password for user root: josehenrique 
3. Re-enter new password: josehenrique 











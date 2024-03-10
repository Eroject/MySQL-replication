#!/bin/bash

design(){

echo ""

echo ""

echo "	                                      ███╗   ███╗██╗   ██╗███████╗ ██████╗ ██╗         "

echo "        	                              ████╗ ████║╚██╗ ██╔╝██╔════╝██╔═══██╗██║         "

echo "        	                              ██╔████╔██║ ╚████╔╝ ███████╗██║   ██║██║   "

echo "        	                              ██║╚██╔╝██║  ╚██╔╝  ╚════██║██║▄▄ ██║██║       "

echo "        	                              ██║ ╚═╝ ██║   ██║   ███████║╚██████╔╝███████╗    "

echo "        	                              ╚═╝     ╚═╝   ╚═╝   ╚══════╝ ╚══▀▀═╝ ╚══════╝    "

echo ""

echo ""

}

user=dba

project_directory="/home/$user/Desktop/final"

replication_bidirectionnelle() {

read -p "<-> Entrez le nom de la base de données : " DB_NAME

read -p "<-> Entrez l'adresse ip de la premiere machine : " master_ip

ssh-copy-id $user@"$master_ip"

configuration_environnement_machine $master_ip

configuration_master_master

echo -e "<-> combien de machines voulez vous connecter ?\n" 

read -r nserver

nserver=$(expr $nserver + 1)

i=1 

#myipadress=$(ifconfig | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}'| head -n 1)

until [ "$i" -eq "$nserver" ]; do

	i=$(expr $i + 1)

	echo -e "<-> donner l'adresse ip N° $i :"

	read -r ipadress

	ssh-copy-id $user@"$ipadress"

	configuration_environnement_machine $ipadress	

	configuration_slave_master

	configuration_slave_slave

	yml_file="logfile.yml"

	logfile_inventory="$project_directory/$yml_file"

	resultfile="/result.txt"

	sed -i "4s|.*|  remote_user: $user|" $logfile_inventory

	file_result="        dest: ${project_directory}${resultfile}"

	sed -i "27s|.*|$file_result|" $logfile_inventory

	ansible-playbook $logfile_inventory

	configuration_master_slave		

done



}



replication_monodirectionnelle() {

read -p "<-> Entrez le nom de la base de données : " DB_NAME

read -p "<-> Entrez l'adresse ip du maitre : " master_ip

ssh-copy-id $user@"$master_ip"

configuration_environnement_machine $master_ip

configuration_master_master

echo -e "<-> combien de machines esclaves voulez vous connecter ?\n" 

read -r nserver

nserver=$(expr $nserver + 1)

i=1 

#myipadress=$(ifconfig | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}'| head -n 1)

until [ "$i" -eq "$nserver" ]; do

	echo -e "<-> donner l'adresse ip N° $i :"

	read -r ipadress

	ssh-copy-id $user@"$ipadress"

	configuration_environnement_machine $ipadress

	i=$(expr $i + 1)

	configuration_slave_master

	configuration_slave_slave	

done



}



configuration_environnement_machine(){

	ipadress=$1

	echo "<-> Voulez-vous configurer votre machine? (y/n)"

	read response

	if [ "$response" == "y" ]; then	

	chainebi="[servers]\nserver1 ansible_host="

	resultat="${chainebi}${ipadress} "

	echo -e "$resultat" > /etc/ansible/hosts

	configuremachine_file="env.yml"

	inventoryconfig="$project_directory/$configuremachine_file"

	sed -i "5s|.*|  remote_user: $user|" $inventoryconfig

	ansible-playbook $inventoryconfig

	fi



}



configuration_slave_master() {

config_file="config.sh"

result="$project_directory/$config_file"

chainedb="DB_NAME="

DBch="${chainedb}${DB_NAME} "

sed -i "3s/.*/$DBch/" $result

chaineid="id=$i"

sed -i "2s/.*/$chaineid/" $result

UTILISATEUR_MYSQL="UTILISATEUR_MYSQL=slave1"

sed -i "4s/.*/$UTILISATEUR_MYSQL/" $result



yml_file="inventory.yml"

inventory="$project_directory/$yml_file"

sed -i "4s|.*|  remote_user: $user|" $inventory

file_copy="        src: $result"

sed -i "13s|.*|$file_copy|" $inventory

file_copy="        bash /home/$user/$config_file"

sed -i "23s|.*|$file_copy|" $inventory

file_copy="        src: ${project_directory}/sql.sh"

sed -i "18s|.*|$file_copy|" $inventory

file_delete="        path: /home/$user/$config_file"

sed -i "26s|.*|$file_delete|" $inventory



chainebi="[servers]\nserver1 ansible_host="

resultat="${chainebi}${ipadress} "

echo -e "$resultat" > /etc/ansible/hosts

ansible-playbook $inventory  



}

configuration_master_master(){

config_file="config.sh"

result="$project_directory/$config_file"

chainedb="DB_NAME="

DBch="${chainedb}${DB_NAME} "

sed -i "3s/.*/$DBch/" $result

chaineid="id=1"

sed -i "2s/.*/$chaineid/" $result

UTILISATEUR_MYSQL="UTILISATEUR_MYSQL=slave1"

sed -i "4s/.*/$UTILISATEUR_MYSQL/" $result



yml_file="inventory.yml"

inventory="$project_directory/$yml_file"

sed -i "4s|.*|  remote_user: $user|" $inventory

sed -i "19s|.*|        dest: /home/$user|" $inventory

file_copy="        src: $result"

sed -i "13s|.*|$file_copy|" $inventory

file_copy="        bash /home/$user/$config_file"

sed -i "23s|.*|$file_copy|" $inventory

file_copy="        src: ${project_directory}/sql.sh"

sed -i "18s|.*|$file_copy|" $inventory

file_delete="        path: /home/$user/$config_file"

sed -i "26s|.*|$file_delete|" $inventory





chainebi="[servers]\nserver1 ansible_host="

resultat="${chainebi}${master_ip} "

echo -e "$resultat" > /etc/ansible/hosts

ansible-playbook $inventory 



}



configuration_slave_slave() {

chainebi="[servers]\nserver1 ansible_host="

resultat="${chainebi}${master_ip} "

echo -e "$resultat" > /etc/ansible/hosts



yml_file="logfile.yml"

logfile_inventory="$project_directory/$yml_file"

resultfile="/result.txt"

file_result="        dest: ${project_directory}${resultfile}"

sed -i "27s|.*|$file_result|" $logfile_inventory

ansible-playbook $logfile_inventory



logpos_file="result.txt"

nom_du_fichier="$project_directory/$logpos_file"

BINLOG_POSITION=$(tail -n 1 "$nom_du_fichier")

BINLOG_FILE_NAME=$(head -n 1 "$nom_du_fichier")



slave_file="slave.sh"

result="$project_directory/$slave_file"

master_valeur_File="valeur_File=$BINLOG_FILE_NAME"

sed -i "3s/.*/$master_valeur_File/" $result

master_valeur_Position="valeur_Position=$BINLOG_POSITION"

sed -i "4s/.*/$master_valeur_Position/" $result

slave_channel="channel=channel1"

sed -i "5s/.*/$slave_channel/" $result

#myipadress=$(ifconfig | grep -oE 'inet [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | awk '{print $2}'| head -n 1)

chaineipmaster="ipmaster="

masteripch="${chaineipmaster}${master_ip} "

sed -i "2s/.*/$masteripch/" $result



yml_file="inventory.yml"

inventory="$project_directory/$yml_file"

sed -i "4s|.*|  remote_user: $user|" $inventory

file_copy="        src: $result"

sed -i "13s|.*|$file_copy|" $inventory

file_copy="        bash /home/$user/$slave_file"

sed -i "23s|.*|$file_copy|" $inventory

file_delete="        path: /home/$user/$slave_file"

sed -i "26s|.*|$file_delete|" $inventory



chainebi="[servers]\nserver1 ansible_host="

resultat="${chainebi}${ipadress} "

echo -e "$resultat" > /etc/ansible/hosts

ansible-playbook $inventory 

}

configuration_master_slave() {

slave_file="result.txt"

nom_du_fichier="$project_directory/$slave_file"

BINLOG_POSITION=$(tail -n 1 "$nom_du_fichier")

BINLOG_FILE_NAME=$(head -n 1 "$nom_du_fichier")

slave_file="slave.sh"

result="$project_directory/$slave_file"

master_valeur_File="valeur_File=$BINLOG_FILE_NAME"

sed -i "3s/.*/$master_valeur_File/" $result

master_valeur_Position="valeur_Position=$BINLOG_POSITION"

sed -i "4s/.*/$master_valeur_Position/" $result

slave_channel="channel=channel$i"

sed -i "5s/.*/$slave_channel/" $result

chaineipmaster="ipmaster="

ipadressch="${chaineipmaster}${ipadress} "

sed -i "2s/.*/$ipadressch/" $result



yml_file="inventory.yml"

inventory="$project_directory/$yml_file"

sed -i "4s|.*|  remote_user: $user|" $inventory

file_copy="        src: $result"

sed -i "13s|.*|$file_copy|" $inventory

file_copy="        bash /home/$user/$slave_file"

sed -i "23s|.*|$file_copy|" $inventory

file_delete="        path: /home/$user/$slave_file"

sed -i "26s|.*|$file_delete|" $inventory



chainebi="[servers]\nserver1 ansible_host="

resultat="${chainebi}${master_ip} "

echo -e "$resultat" > /etc/ansible/hosts

ansible-playbook $inventory

}



sql() { 

slave_file="sql.sh"

sql_file="$project_directory/$slave_file"

bash $slave_file

}



environment_configuration(){

apt install -y mysql-server

apt install -y openssh-server

apt install -y ansible



mkdir -p /etc/ansible

touch /etc/ansible/hosts



chmod a+wxr /etc/ansible        # Correction: Ajout d'un espace ici

chmod a+wxr /etc/ansible/hosts  # Correction: Ajout d'un espace ici



ssh-keygen



}

ch=0

until [ "$ch" -eq 5 ]; do

clear

design

    echo -e "					<1>  configurer replication_bidirectionnelle\n\n					<2>  configurer la replication_monodirectionnelle\n\n					<3>  SQL \n\n					<4>  preparation de l'environnement\n\n					<5>  Quitter\n"

    echo -e "Enter Your Choice from above menu: "

    read -r ch

    clear



    if [ $ch -gt 5 ] || [ $ch -eq 0 ]; then

        echo "<-> veillez choisir un chiffre entre 1 et 5\n"

    fi



    case $ch in

    1) replication_bidirectionnelle;;

    2) replication_monodirectionnelle ;;

    3) sql ;;

    4) environment_configuration ;;

    esac



done




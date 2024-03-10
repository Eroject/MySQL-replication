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

afficher_menu() {
    
    clear
    design
    echo -e "\n"
    echo -e "					<1>  Créer une nouvelle base de données"
    echo -e "\n"
    echo -e "					<2>  Choisir une base de données existante et effectuer des opérations sur les tables"
    echo -e "\n"
    echo -e "					<3>  Supprimer une base de données"
    echo -e "\n"
    echo -e "					<4>  Afficher le statut du maître (SHOW MASTER STATUS)"
    echo -e "\n"
    echo -e "					<5>  Afficher le statut de l'esclave (SHOW SLAVE STATUS)"
    echo -e "\n"
    echo -e "					<6>  Quitter le programme\n\n"
    read -p "<-> Veuillez saisir le numéro correspondant à votre choix: " choix
    clear
}
operations_menu() {

    while true; do

        clear

        design

        echo -e "<-> Que voulez-vous faire avec la base de données $db_name? \n\n"
        echo -e "					<1>  Afficher les Tables"
        echo -e ""
        echo -e "					<2>  Afficher la Structure d'une Table"
       	echo -e ""
        echo -e "					<3>  Sélectionner des Données"
        echo -e ""
        echo -e "					<4>  Insérer des Données"
        echo -e ""
        echo -e "					<5>  Supprimer des Données"
        echo -e ""
        echo -e "					<6>  Supprimer une Table"
        echo -e ""
        echo -e "					<7>  Copier les Données d'une Table dans une Autre"
        echo -e ""
        echo -e "					<8>  Créer une Nouvelle Table"
        echo -e ""
        echo -e " 					<9>  Quitter"
	echo -e ""
        read -p "<-> Choisissez un numéro : " choice

        case $choice in

            1)
                afficher_tables
                ;;

            2)
                afficher_structure_table
                ;;

            3)
                selectionner_donnees
                ;;

            4)
                inserer_donnees
                ;;

            5)
                supprimer_donnees
                ;;

            6)
                supprimer_table
                ;;

            7)
                copier_donnees_entre_tables
                ;;

            8)
                creer_nouvelle_table
                ;;

            9)
                return
                ;;

            *)
                afficher_message_erreur "Option invalide. Veuillez sélectionner un numéro valide."
                ;;

        esac

    done

}

afficher_message_erreur() {
    echo "$1"
    read -p "Appuyez sur Entrée pour continuer..."
}

afficher_tables() {
    sudo mysql -uroot -e "USE $db_name; SHOW TABLES;"
    read -p "Appuyez sur Entrée pour revenir au menu..."
}

afficher_structure_table() {
    clear
    echo "Tables disponibles dans la base de données $db_name:"
    sudo mysql -uroot -e "USE $db_name; SHOW TABLES;"

    echo "Liste des tables existantes :"

    tables=$(sudo mysql -uroot -e "USE $db_name; SHOW TABLES;" | grep -Ev "(Tables_in_$db_name)")

    echo "Quelle est la table que vous voulez afficher sa structure? "
    
    select selected_table in $tables; do
        if [ -n "$selected_table" ]; then
            echo "Vous avez choisi la table : $selected_table"
            echo "Structure de la table $selected_table :"
            sudo mysql -u root -e "USE $db_name; DESCRIBE $selected_table;"
            read -p "Appuyez sur Entrée pour revenir au menu..."
        else
            afficher_message_erreur "Choix invalide. Veuillez sélectionner une table valide."
        fi  
        break
    done
}





selectionner_donnees() {

    # Afficher les tables disponibles dans la base de données
    echo "Tables disponibles dans la base de données $db_name:"
    sudo mysql -uroot -e "USE $db_name; SHOW TABLES;"

    # Liste des tables existantes
    echo "Liste des tables existantes :"
    tables=$(sudo mysql -uroot -e "USE $db_name; SHOW TABLES;" | grep -Ev "(Tables_in_$db_name)")

    # Sélection de la table
    echo "Quelle est la table que vous voulez afficher ?"
    select selected_table in $tables; do
        if [ -n "$selected_table" ]; then
            echo "Vous avez choisi la table : $selected_table"
            echo "Colonnes disponibles dans la table $selected_table:"

            # Afficher les colonnes avec des numéros
            column_number=1
            sudo mysql -uroot -e "USE $db_name; SHOW COLUMNS FROM $selected_table;" | grep -Ev "(Field)" | while read -r column; do
                echo "$column_number) $column"
                ((column_number++))
            done

            read -p "Entrez le numéro de la colonne à sélectionner (0 pour tout sélectionner) : " select_column_number

            # Récupérer le nom de la colonne sélectionnée
            if [ "$select_column_number" -eq 0 ]; then
                selected_columns="*"
            else
                selected_columns=$(sudo mysql -uroot -e "USE $db_name; SHOW COLUMNS FROM $selected_table;" | grep -Ev "(Field)" | sed -n "${select_column_number}p" | awk '{print $1}')
            fi

            read -p "Entrez la condition WHERE (ou appuyez sur Enter pour tout sélectionner) : " where_condition

            if [ -n "$selected_columns" ]; then
                if [ -n "$where_condition" ]; then
                    sudo mysql -uroot -e "USE $db_name; SELECT $selected_columns FROM $selected_table WHERE $where_condition;"
                else
                    sudo mysql -uroot -e "USE $db_name; SELECT $selected_columns FROM $selected_table;"
                fi
                read -p "Appuyez sur Entrée pour continuer..."
            else
                echo "Numéro de colonne invalide. Veuillez sélectionner un numéro de colonne valide."
            fi
            break
        else
            echo "Choix invalide. Veuillez sélectionner une table valide."
        fi
    done 
}


inserer_donnees() {
    clear
    echo "Tables disponibles dans la base de données $db_name:"
    sudo mysql -uroot -e "USE $db_name; SHOW TABLES;"

    echo "Liste des tables existantes :"
    tables=$(sudo mysql -uroot -e "USE $db_name; SHOW TABLES;" | grep -Ev "(Tables_in_$db_name)")

    # Sélection de la table
    echo "Quelle est la table que vous voulez inserer ?"
    select selected_table in $tables; do
        if [ -n "$selected_table" ]; then
            echo "Vous avez choisi la table : $selected_table"
            echo "Colonnes disponibles dans la table $selected_table:"

            sudo mysql -uroot -e "USE $db_name; SHOW COLUMNS FROM $selected_table;"

            values=()

            columns=($(sudo mysql -uroot -e "USE $db_name; SHOW COLUMNS FROM $selected_table;" | grep -Ev "(Field)" | awk '{print $1}'))

            for column_name in "${columns[@]}"; do
                while true; do
                    read -p "Entrez la valeur pour la colonne $column_name : " column_value
                    if [ -n "$column_value" ]; then
                        values+=("$column_name='$column_value'")
                        break
                    else
                        echo "La valeur ne peut pas être vide. Veuillez entrer une valeur."
                    fi
                done
            done

            if [ "${#values[@]}" -ne 0 ]; then
                values_str=$(IFS=,; echo "${values[*]}")
                sudo mysql -uroot -e "USE $db_name; INSERT INTO $selected_table SET $values_str;"
                afficher_message_erreur "Les données ont été insérées avec succès dans la table '$selected_table'."
            else
                afficher_message_erreur "Aucune valeur spécifiée. Aucune insertion n'a été effectuée."
            fi

            break
        else
            afficher_message_erreur "Choix invalide. Veuillez sélectionner une table valide."
        fi
    done
}


supprimer_donnees() {
    clear

    echo "Tables disponibles dans la base de données $db_name:"

    # Utilisation de l'option -N pour obtenir une sortie sans le nom de la colonne
    tables=$(sudo mysql -uroot -N -e "USE $db_name; SHOW TABLES;")

    # Sélection de la table
    echo "Quelle est la table que vous voulez supprimer ?"

    select selected_table in $tables; do
        if [ -n "$selected_table" ]; then
            echo "Vous avez choisi la table : $selected_table"
            echo "Colonnes disponibles dans la table $selected_table:"

            # Afficher les colonnes avec des numéros
            column_number=1

            # Utilisation de l'option -N pour obtenir une sortie sans le nom de la colonne
            columns=$(sudo mysql -uroot -N -e "USE $db_name; SHOW COLUMNS FROM $selected_table;")
            
            echo "$columns" | while read -r column; do
                echo "$column_number) $column"
                ((column_number++))
            done

            read -p "Entrez le numéro de la colonne pour la condition WHERE (0 pour tout supprimer) : " delete_column_number

            # Récupérer le nom de la colonne sélectionnée
            if [ "$delete_column_number" -ne 0 ]; then
                delete_column=$(echo "$columns" | sed -n "${delete_column_number}p" | awk '{print $1}')
            fi

            read -p "Entrez la valeur à supprimer dans la colonne '$delete_column' (par exemple, id=7) : " delete_condition

            if [ -n "$delete_column" ] || [ -z "$delete_condition" ]; then
                if [ -n "$delete_condition" ]; then
                    # Utilisez des guillemets simples autour de la valeur pour éviter des problèmes de format
                    sudo mysql -uroot -e "USE $db_name; DELETE FROM $selected_table WHERE $delete_condition;"
                else
                    sudo mysql -uroot -e "USE $db_name; DELETE FROM $selected_table;"
                fi

                if [ $? -eq 0 ]; then
                    afficher_message_erreur "Les données ont été supprimées avec succès de la table '$selected_table'."
                else
                    afficher_message_erreur "Erreur lors de la suppression des données de la table '$selected_table'."
                fi
            else
                afficher_message_erreur "Numéro de colonne invalide. Veuillez sélectionner un numéro de colonne valide."
            fi

            break
        else
            echo "Choix invalide. Veuillez sélectionner une table valide."
        fi
    done
}





supprimer_table() {

    clear

    echo "Tables disponibles dans la base de données $db_name:"

    sudo mysql -uroot -e "USE $db_name; SHOW TABLES;"

    echo "Liste des tables existantes :"

    tables=$(sudo mysql -uroot -e "USE $db_name; SHOW TABLES;" | grep -Ev "(Tables_in_$db_name)")

    echo "Quelle est la table que vous voulez supprimer ?"

    select selected_table in $tables; do

        if [ -n "$selected_table" ]; then

            echo "Vous avez choisi la table : $selected_table"

            read -p "Voulez-vous vraiment supprimer la structure de la table $selected_table ? (Y/N): " confirmation

            if [ "$confirmation" == "Y" ] || [ "$confirmation" == "y" ]; then

                sudo mysql -uroot -e "USE $db_name; DROP TABLE $selected_table;"

                afficher_message_erreur "La structure de la table '$selected_table' a été supprimée avec succès."

            else

                afficher_message_erreur "Suppression annulée. La structure de la table n'a pas été supprimée."

            fi

        else

            afficher_message_erreur "Choix invalide. Veuillez sélectionner une table valide."

        fi

        break

    done
}

copier_donnees_entre_tables() {
    clear

    echo "Tables sources dans la base de données  $db_name:"
    tables=$(sudo mysql -uroot -N -e "USE $db_name; SHOW TABLES;")

    select source_table in $tables; do
        if [ -n "$source_table" ]; then
            break
        else
            echo "Option invalide. Veuillez sélectionner une table source valide."
        fi
    done

    clear

    echo "Tables destinataires pour copier les données dans la base de données $db_name:"
    select destination_table in $tables; do
        if [ -n "$destination_table" ]; then
            break
        else
            echo "Option invalide. Veuillez sélectionner une table de destination valide."
        fi
    done

    clear

    echo "Colonnes disponibles dans la table source $source_table:"
    sudo mysql -uroot -e "USE $db_name; SHOW COLUMNS FROM $source_table;"

    while true; do
        read -p "Entrez le nom de la colonne à copier (ou tapez 'tout' pour copier toute la table) : " copy_column_name

        if [ "$copy_column_name" == "tout" ]; then
            source_columns=$(sudo mysql -uroot -N -e "USE $db_name; SHOW COLUMNS FROM $source_table;" | awk '{print $1}')

            # Check if columns exist in the destination table
            for source_column in $source_columns; do
                column_exists=$(sudo mysql -uroot -e "USE $db_name; SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '$db_name' AND TABLE_NAME = '$destination_table' AND COLUMN_NAME = '$source_column';")

                if [ -z "$column_exists" ]; then
                    echo "La colonne '$source_column' n'existe pas dans la table de destination '$destination_table'."
                    return
                fi
            done

            # Copy all data
            sudo mysql -uroot -e "USE $db_name; INSERT INTO $destination_table SELECT * FROM $source_table;"
            afficher_message_erreur "Les données ont été copiées avec succès de la table '$source_table' vers la table '$destination_table'."
            return
        else
            column_exists=$(sudo mysql -uroot -e "USE $db_name; SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '$db_name' AND TABLE_NAME = '$destination_table' AND COLUMN_NAME = '$copy_column_name';")

            if [ -z "$column_exists" ]; then
                echo "La colonne '$copy_column_name' n'existe pas dans la table de destination '$destination_table'."
                return
            fi

            # Copy the specified column
            sudo mysql -uroot -e "USE $db_name; INSERT INTO $destination_table ($copy_column_name) SELECT $copy_column_name FROM $source_table;"
            afficher_message_erreur "La colonne '$copy_column_name' a été copiée avec succès de la table '$source_table' vers la table '$destination_table'."
            return
        fi
    done
}





creer_nouvelle_table() {
    clear	
    read -p "Entrez le nom de la nouvelle table : " new_table_name
    colonnes=()

    while true; do
        read -p "Entrez le nom de la colonne (ou tapez 'fin' pour terminer) : " colonne_name

        if [ "$colonne_name" == "fin" ]; then
            break
        fi

        # Assurezque le  nom de la colonne n'est pas vide
        if [ -z "$colonne_name" ]; then
            echo "Le nom de la colonne ne peut pas être vide. Veuillez saisir un nom de colonne valide."
            continue
        fi

        read -p "Entrez le type de données pour la colonne $colonne_name : " colonne_type

        # Assurez que le type de données de la colonne n'est pas vide
        if [ -z "$colonne_type" ]; then
            echo "Le type de données de la colonne ne peut pas être vide. Veuillez saisir un type de données valide."
            
            continue
        fi

        colonnes+=("$colonne_name $colonne_type")
    done

    if [ "${#colonnes[@]}" -eq 0 ]; then
        echo "Aucune colonne spécifiée. La table doit avoir au moins une colonne."
        return
    fi

    colonnes_def=$(IFS=,; echo "${colonnes[*]}")

    echo "Commande MySQL générée :"
    echo "USE $db_name; CREATE TABLE $new_table_name ($colonnes_def);"

    sudo mysql -uroot -e "USE $db_name; CREATE TABLE $new_table_name ($colonnes_def);"

    if [ $? -eq 0 ]; then
        echo "La nouvelle table '$new_table_name' a été créée avec succès."
        operations_menu
    else
        echo "Erreur lors de la création de la table."
    fi
}


while true; do
    afficher_menu

    case $choix in
        1)
            read -p "Veuillez saisir le nom de la nouvelle base de données: " nouvelle_bd
            sudo mysql -uroot -e "CREATE DATABASE $nouvelle_bd;"
            afficher_message_erreur "La base de données '$nouvelle_bd' a été créée avec succès."
            ;;
        2)
            echo "Liste des bases de données existantes:"
            databases=$(sudo mysql -uroot -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

            select db_name in $databases; do
                if [ -n "$db_name" ]; then
                    echo "Vous avez choisi la base de données: $db_name"
                    operations_menu
                else
                    afficher_message_erreur "Choix invalide. Veuillez sélectionner une base de données valide."
                fi
                break
            done
            ;;
        3)
	     echo "Bases de données disponibles:"
        databases=$(sudo mysql -uroot -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")
        select db_name in $databases; do
            if [ -n "$db_name" ]; then
                echo "Vous avez choisi la base de données: $db_name"
                read -p "Voulez-vous vraiment supprimer la base de données '$db_name'? (Y/N): " confirmation
                if [ "$confirmation" == "Y" ] || [ "$confirmation" == "y" ]; then
                    sudo mysql -uroot -e "DROP DATABASE IF EXISTS $db_name;"
                    afficher_message_erreur "La base de données '$db_name' a été supprimée avec succès."
                else
                    afficher_message_erreur "Suppression annulée. La base de données n'a pas été supprimée."
                fi
            else
                afficher_message_erreur "Choix invalide. Veuillez sélectionner une base de données valide."
            fi
            break
        done
        ;;
        4)
            sudo mysql -uroot -e "SHOW MASTER STATUS\G;"
            read -p "Appuyez sur Entrée pour revenir au menu..."
            ;;
        5)
            sudo mysql -uroot -e "SHOW SLAVE STATUS\G;"
            read -p "Appuyez sur Entrée pour revenir au menu..."
            ;;
        6)
            afficher_message_erreur "Programme terminé."
            exit 0
            ;;
        *)
            afficher_message_erreur "Choix non valide. Veuillez saisir un numéro valide."
            ;;
    esac
done

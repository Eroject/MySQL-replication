**Replication Mysql

L'application Replication Mysql simplifie la mise en place de réplications unidirectionnelles et bidirectionnelles pour les bases de données MySQL. Elle utilise le fichier "projet.sh" pour l'installation et la configuration, ainsi que le fichier "sql.sh" envoyé par Ansible pour faciliter la manipulation de la réplication.

###Installation et Configuration:

>>Ajustez le chemin du répertoire MySQL :

Avant d'exécuter le script "projet.sh" disponible dans le dossier mysql veuillez:

1- ajuster le chemin du répertoire MySQL dans la variable projet_directory en l'ouvrant avec un éditeur du texte :

projet_directory="/chemin/vers/mysql"

2- Il est impératif que chaque machine participant à la réplication ait le même nom d'utilisateur.

3-il est tout aussi crucial d'ajuster la variable "user" dans le fichier 'projet.sh' en remplaçant par votre nom d'utilisateur.
user="votre_nom_utilisateur"


>>Fichier "sql.sh" pour la manipulation fluide :

Chaque machine participant à la réplication recevra le fichier "sql.sh" à executé, situé dans "/home", pour faciliter la manipulation de la réplication.
Note : Les machines à configurer doivent contenir SSH pour permettre une communication efficace entre les différents nœuds de réplication.

###Utilisation
>>Pour configurer la réplication, vous aurez besoin des informations suivantes :

-Nom de la base de données
-Adresses IP des machines participant à la réplication
-Nombre de machines participant
-Étapes pour la Réplication

>>Installation de MySQL (Optionnel) :

Au cas où les machines ne seraient pas déjà configurées avec MySQL, le script propose une option d'installation automatique.

>>Configuration de la Réplication :

Exécutez le script "projet.sh" sur la machine configuratrice.
Choisissez l'option " Réplication monodirectionnelle / Réplication bidirectionnelle".
Fournissez le nom de la base de données, les adresses IP des machines participantes et leur nombre.

>>Préparation de l'Environnement (Optionnel) :

L'option "Préparation de l'Environnement" permet de configurer la machine configuratrice.

Note : Si nécessaire, le script peut installer MySQL sur les machines lors de la configuration de la réplication.

###Rapport détaillé
Pour des informations plus détaillées sur l'application et son fonctionnement, veuillez consulter le rapport PDF inclus dans le répertoire du projet.

REMARQUE :UNE VIDEO DEMONSTRATIVE EST DISPONIBLE DANS LE DOSSIER 'Video_Demonstration_Projet'

###AUTEUR
AJALE Saad

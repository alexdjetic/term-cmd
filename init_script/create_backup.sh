#!/bin/bash
# Author: Djetic Alexandre
# Date: 16/02/2024
# Modified: 07/03/2024
# Description: This script makes a backup of all files in the /home directory into /var/backup

set -u

# Cette fonction crée le dossier de backup si il est pas présent
function check_create_backup_dir_exist {
  # $1 : backup dir
  [ -d "$1" ] || mkdir -p "$1"
}

# Cette fonction donne le nom de la sauvegarde finale
function get_backup_file_name {
  # $1: le fichier contenant date et numéro actuelle
  if [ -f "$1" ]; then
    BACKUP_NUMBER=$(awk 'NR==2 {print $1}' "$1") # Second line of the number file
    echo "backup_$(date +'%Y-%m-%d')-${BACKUP_NUMBER}.tar.gz"
  else
    echo "backup_$(date +'%Y-%m-%d').tar.gz"
  fi
}

# Cette fonction crée une backup
function make_backup {
  # $1: backup full path
  # $2: src directory
  # commande de backup
  local backup_file="$1"
  local src_dir="$2"

  tar czf "$backup_file" -C "$src_dir" . > /dev/null 2>&1 # -C supprime le chemin absolut

  # selon le retour de commande, affichez un message différent
  if [ $? -eq 0 ]; then
    logger "create_backup.sh: sauvegarde de $1 depuis $2 OK"
    return 0
  else
    logger "create_backup.sh: sauvegarde de $1 depuis $2 NOK"
    return 1
  fi
}

# Cette fonction gère le numéro de sauvegarde(incrémentation et initialisation)
function set_backup_number {
  # $1: le fichier contenant date et numéro actuelle
  CURRENT_DATE=$(date +'%Y-%m-%d') # première ligne de $1
  BACKUP_DATE=$(awk 'NR==1 {print $1}' "$1") # deuxièmes ligne de $1

  # test si la date sont identique sinon le fichier est initialiser
  if  [ "$CURRENT_DATE" == "$BACKUP_DATE" ]; then
    BACKUP_NUMBER=$(awk 'NR==2 {print $1}' "$1")
    echo "$(date +'%Y-%m-%d')" > "$1"
    echo "$((BACKUP_NUMBER + 1))" >> "$1"
    logger "create_backup.sh: incrémentation du compteur de $BACKUP_NUMBER à $((BACKUP_NUMBER + 1))..."
  else
    echo "$(date +'%Y-%m-%d')" > "$1"
    echo "1" >> "$1"
  fi
}

# Cette fonction vérifie si un utilisateur est autorisé pour la sauvegarde
function user_allow {
  # $1: utilisateur(s) du system
  local user="$1"
  local white_list_file="/var/backup/white_list_user.txt"
  
  # check fichier de white list existe bien
  if [ ! -f "$white_list_file" ]; then
    logger "create_backup.sh: le fichier ${white_list_file} n'éxiste pas..."
    return 1
  fi

  #check est bien dans la white list
  if grep -q "$user" "$white_list_file"; then
    logger "create_backup.sh: ${user} est autoriser pour réaliser sa sauvegarde"
    return 0
  else
    logger "create_backup.sh: ${user} n'est autoriser pas pour réaliser sa sauvegarde"
    return 1
  fi
}


# Cette fonction vérifie que toutes les conditions préalables sont valides pour la sauvegarde
function check_backup_condition_ok {
  # $1: utilisateur(s) du system
  local user="$1"
  local HOMEDIR=$(getent passwd "$user" | cut -d: -f6) #obtient homedir de l'utilisateur
  local USER_SYS_EXIST=$(getent passwd "$user") > /dev/null
  local cpt_finale=3
  local cpt_tmp=0
  
  # Check si l'utilisateur est autorisé à sauvegarder
  if user_allow "$user"; then
    logger "create_backup.sh: l'utilisateur ${user} est autorisé à réaliser sa sauvegarde."
    cpt_tmp=$((cpt_tmp + 1))
  else
    logger "create_backup.sh: l'utilisateur ${user} n'est pas autorisé à réaliser sa sauvegarde."
    return 1
  fi
  
  # Check si l'utilisateur existe dans le système
  if [ ! -z "$USER_SYS_EXIST" ]; then
    logger "create_backup.sh: l'utilisateur ${user} existe."
    cpt_tmp=$((cpt_tmp + 1))
  else
    logger "create_backup.sh: l'utilisateur ${user} n'existe pas."
    return 1
  fi
  
  # Check si le homedir de l'utilisateur existe
  if [ -d "$HOMEDIR" ]; then
    logger "create_backup.sh: le homedir de l'utilisateur ${user} existe."
    cpt_tmp=$((cpt_tmp + 1))
  else
    logger "create_backup.sh: le homedir de l'utilisateur ${user} n'existe pas."
    return 1
  fi
  
  # Vérifie si toutes les conditions sont remplies avec les 2 compteurs
  if [ "$cpt_finale" -eq "$cpt_tmp" ]; then
    logger "create_backup.sh: toutes les conditions sont OK pour la sauvegarde de ${user}."
    return 0
  else
    logger "create_backup.sh: toutes les conditions ne sont pas OK pour la sauvegarde de ${user}."
    return 1
  fi
}

# Cette fonction sauvegarde(copie) un/plusieurs utilisateur(s) du système dans le répertoire $PWD/user_tmp
function backup_all_user_in_tmp {
  # $1: utilisateur(s) du system
  # $2: dossier temporaire de sauvegarde
  for SYS_USER in "$@"
  do
    HOMEDIR=$(getent passwd "$SYS_USER" | cut -d: -f6) #obtient homedir de SYSUSER

    # test que le home dir de $SYS_USER exist et $SYS_USER existe bien
    if check_backup_condition_ok "$SYS_USER"; then
        #copie de dossier temporaire dans le dossier de sauvegarde temporaire
	      make_backup "/tmp/backup/$SYS_USER.tar.gz" "$HOMEDIR"
    else
      logger "create_backup.sh: sauvegarde de /tmp/$SYS_USER.tar.gz NOK... le homedir de $SYS_USER n'éxiste pas ou $SYS_USER n'existe pas..."
    fi
  done
}

# check qu'un argument est donnée et page d'aide
if [ $# -lt 1 ] || [ "$1" == "-h" ] || [ "$1"  == "--help" ]; then
  echo "ce script le homedir d'un/des utilisateur(s) dans le fichiers /var/backup/"
  echo "Usage:"
  echo "- sudo ./create_backup.sh all: sauvegarde/backup tout les utilisateurs"
  echo "- sudo ./create_backup.sh user1: sauvegarde/backup user1"
  echo "- sudo ./create_backup.sh user1 user2 ...: sauvegarde/backup user1, user2, ..."
  echo "--- ce script se lance avec un compte accès privilégié ---"
  exit 0
fi

# check lancer avec accès sudo/root
if [ ! $EUID -eq 0 ]; then
  echo "require root/sudo access..."
  exit 1
fi

# variable d'envirronement
BACKUP_NUMBER_FILE="/var/backup/backup_number.txt" # File contain date + number
BACKUP_FILE=$(get_backup_file_name "$BACKUP_NUMBER_FILE")
BACKUP_DIR="/var/backup"
BACKUP_TMP_DIR="/tmp/backup"

# Check que $BACKUP_DIR et $BACKUP_TMP_DIR existe sinon il est crée
check_create_backup_dir_exist "$BACKUP_DIR"
check_create_backup_dir_exist "$BACKUP_TMP_DIR"
touch "$BACKUP_NUMBER_FILE"

# création d'une archive temporaire pour l'utilisateur X, ... selon les arguments données
if [ "$1" == "all" ]; then
  ALL_USER=$(cat /etc/passwd | sed "s/:/ /g" | awk '{print $1}')
  backup_all_user_in_tmp $ALL_USER
else
  backup_all_user_in_tmp "$@"
fi

# backup finale contenant, user1.tar.gz, user2.tar.gz, ...
FINAL_BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE}"
TMP_BACKUP_EMPTY=$(find "$BACKUP_TMP_DIR" -type f -print -quit) 

# check que backup temporaire pas vide
if [ -z "$TMP_BACKUP_EMPTY" ]; then
  logger "create_backup.sh: dossier de sauvegarde vide, pas be sauvegarde à faire"
  exit 1
fi

# Crée la sauvegarde finale si le dossier temporaire n'est pas vide
if make_backup "$FINAL_BACKUP_FILE" "$BACKUP_TMP_DIR"; then
  #si la backup est validé avec le code de retour de commande, initialise/incrémente un compteur avec une date
  set_backup_number "$BACKUP_NUMBER_FILE"
fi

# supprime le fichier temporaire
rm -rf "$BACKUP_TMP_DIR"
exit 0

#!/bin/bash
# Author: Djetic Alexandre
# Date: 09/03/2022
# Modified: 09/03/2024
# Description: This script checks that create_backup.sh works as expected, even in limit cases

#-------------------------- test condition --------------------
# user: etudiant
# prefix commande: sudo
# directory: /home/etudiant
# log file: /home/etudiant/test_backup.log
#--------------------------------------------------------------

#------------------ main configuration directory --------------
# backup directory: /var/backup
# white list: backup_number.txt
# count number: white_list_user.txt
#--------------------------------------------------------------

#-------------------------- test user -------------------------
# - test1
# - test2
# - test3
# - test4
# - test5
#---------------------------------------------------------------

#-------------------------- case to test ----------------------
# 1) show affichage help menu => exit code 0
# 2) backup 1 user exist and check that all ok => exit code 0
# 3) backup 2 user exist and check that all ok => exit code 0
# 4) backup user don't exist => exit code 1
# 5) backup user don't whit list => exit code 1
#---------------------------------------------------------------

set -u

# creer un utilisateur
function add_test_user {
  # $1 : utilisateur(s) du system
  for arg in "$@"
  do
    local user="$arg"
    local user_exist=$(cat /etc/passwd | grep "$user")

    # vérifie si l'utilisateur existe déjà
    if [ -z "$user_exist" ]; then
      echo "création de l'utilisateur ${user}"
      sudo useradd "$user"
      echo "test de ${user}" > "/home/${user}/test_${user}.txt"
    else
      echo "${user} éxiste déja"
    fi
  done
}

# supprime un utilisateur du system
function del_test_user {
  # $1 : utilisateur du system
  for arg in "$@"
  do
    local user="$arg"
    local user_exist=$(cat /etc/passwd | grep "$user")
    local homedir=$(getent passwd "test1" | cut -d: -f6) #obtient de homedir 
    
    if [ ! -z "$user_exist" ]; then
      sudo userdel -r "$user"
      rm "/var/mail/$user"    
      rm "$homedir"
      echo "suppretion de ${user}"
    fi
  done
}

# supprime un utilisateur du system
function del_test_user {
  # $1 : utilisateur du system
  local user="$1"
  local user_exist=$(cat /etc/passwd | grep "$user")
  local homedir=$(getent passwd "$user" | cut -d: -f6) #obtient le homedir

  if [ ! -z "$user_exist" ]; then
    userdel -r "$user"
    rm -rf "/var/mail/$user"
    rm -rf "$homedir"
    echo "Suppression de l'utilisateur ${user}"
  fi
}

# Cette fonction donne le nom de la sauvegarde finale
function get_backup_file_name {
  # $1: le fichier contenant date et numéro actuelle
  if [ -f "$1" ]; then
    BACKUP_NUMBER=$(($(awk 'NR==2 {print $1}' "$1") - 1)) # Second line of the number file
    echo "backup_$(date +'%Y-%m-%d')-${BACKUP_NUMBER}.tar.gz"
  else
    echo "backup_$(date +'%Y-%m-%d').tar.gz"
  fi
}

# Cette focntion compare si 2 fichier/dossier sont identique
function compare {
  # $1 : un dossier/fichier
  # $2 : un dossier/fichier
  # $3 : numero de test
  local dir1="$1"
  local dir2="$2"
  local num="$3"

  # compare les deux
  diff -r "$1" "$2" > /dev/null
  
  if [ -e "$dir1" ] && [ -e "$dir2" ]; then
    if [ $? -eq 0 ]; then
      return 0
    else
      return 1
    fi
  fi
}

# Cette focntion test la sauvegarde d'un utilisateur
function test_backup_1_user {
  # $1 : utilisateut du systeme
  # $2 : numéro de test
  local test_num="$2"
  local log_file="/home/oem/test_backup.log"
  local BACKUP_DIR="/var/backup"
  local BACKUP_TMP_DIR="/tmp/backup_test"
  local backup_file_number="/var/backup/backup_number.txt"
  local user="$1"
  local backup_name=$(get_backup_file_name "$backup_file_number")
  local homedir=$(getent passwd "$user" | cut -d: -f6) #obtient le homedir

  # décompresser l'archive
  tar -xzvf "$BACKUP_DIR/$backup_name" -C "$BACKUP_TMP_DIR" > "$log_file" 

  # dossier temporaire pour test1
  mkdir -p "$BACKUP_TMP_DIR/test1"
  tar -xzvf "$BACKUP_TMP_DIR/test1.tar.gz" -C "$BACKUP_TMP_DIR/test1" >> "$log_file"

  if compare "$homedir" "$BACKUP_TMP_DIR/test1" "$test_num"; then
    echo "test ${test_num}: la sauvegarde de ${homedir} et ${BACKUP_TMP_DIR/test1} sont identiques"
    echo "la sauvegarde de ${user} est un succès"
    return 0
  else
    echo "test ${test_num}: la sauvegarde de ${homedir} et ${BACKUP_TMP_DIR/test1} ne sont pas identiques"
    echo "la sauvegarde de ${user} à échouée"
    return 1
  fi
}

# Cette focntion néttoie toutes les archives de test
function cleaning {
  # $@ : une list d'utilisateur
  BACKUP_DIR="/var/backup"
  BACKUP_TMP_DIR="/tmp/backup_test"

  #netoie archive
  rm -rf "$BACKUP_TMP_DIR/*"
  rm -rf "$BACKUP_DIR/*"

  #netoie utilisateur
  for user in $@
  do
    del_test_user "$user"
  done
}

# check lancer avec accès sudo/root
if [ ! $EUID -eq 0 ]; then
  echo "require root/sudo access..."
  exit 1
fi

#----------------- env var -----------------
LOG_FILE="/home/oem/test_backup.log"
BACKUP_DIR="/var/backup"
BACKUP_TMP_DIR="/tmp/backup_test"
#-------------------------------------------

#----------------- test lab ----------------
touch "$LOG_FILE"

for i in {1..5}
do
  rm -rf "/home/test$i"
  del_test_user "test$i" 2> /dev/null
done
#-------------------------------------------

#----------------- test 1: affichage menu aide -----------------
echo "--- test 1: affichage de l'aide ---"
expect_output="ce script le homedir d'un/des utilisateur(s) dans le fichiers /var/backup/
Usage:
- sudo ./create_backup.sh all: sauvegarde/backup tout les utilisateurs
- sudo ./create_backup.sh user1: sauvegarde/backup user1
- sudo ./create_backup.sh user1 user2 ...: sauvegarde/backup user1, user2, ...
--- ce script se lance avec un compte accès privilégié ---"
output=$(./create_backup.sh --help)


if [ "$expect_output" == "$output" ]; then
  echo "test 1: la page de manuel est bien afficher, OK"
else
  echo "test 1: la page de manuel n'est pas afficher, NOK"
fi

echo -e "-----------------------------------\n"
#---------------------------------------------------------------

#----------------- test 2: sauvegarde d'un utilisateur -----
echo "--- test 2: sauvegarde d'un utilisateur ---"
add_test_user "test1"
echo "test1" > "$BACKUP_DIR/white_list_user.txt"

# sauvegarde 
./create_backup.sh "test1"

# check que la sauvegarde à fonctionner
if [ $? -ne 0 ]; then
  echo "test 2: NOK, la sauvegarde n'a pas fonctionnée"
else
  if test_backup_1_user "test1" "2"; then
    echo "test 2: OK"
  else
    echo "test 2: NOK"
  fi
fi

cleaning "test1" #netoyage après test
echo -e "--------------------------------------------\n"
#---------------------------------------------------------------

#----------------- test 3: sauvegarde de 2 utilisateurs -----
echo "--- test 3: sauvegarde de 2 utilisateurs ---"
add_test_user "test1" "test2"
echo "test1 test2" > "$BACKUP_DIR/white_list_user.txt"

# sauvegarde 
./create_backup.sh "test1" "test2"

# check que la sauvegarde à fonctionner
if [ $? -ne 0 ]; then
  echo "test 3: NOK, la sauvegarde n'a pas fonctionnée"
else
  if test_backup_1_user "test1" "3" && test_backup_1_user "test2" "3"; then
    echo "test 3: OK"
  else
    echo "test 3: NOK"
  fi
fi

cleaning "test1" "test2" #netoyage après test
echo -e "--------------------------------------------\n"
#---------------------------------------------------------------

#----------------- test 4: sauvegarde d'un utilisateur inexistant -----
echo "--- test 4: sauvegarde d'un utilisateur inexistant---"
echo "azerty123" > "$BACKUP_DIR/white_list_user.txt"

# sauvegarde 
./create_backup.sh "azerty123"

# check que la sauvegarde à fonctionner
if [ $? -eq 0 ]; then
  echo "test 4: NOK, la sauvegarde a fonctionnée ou elle ne devrait pas"
else
  echo "test 4: OK, la sauvegarde n'a pas fonctionnée comme convenue"
fi

cleaning
echo -e "--------------------------------------------------\n"
#---------------------------------------------------------------

#----------------- test 5: sauvegarde d'une utilisateur non autorisé -----
echo "--- test 5:  sauvegarde d'un utilisateur non autorisé ---"
add_test_user "test1"
echo "" > "$BACKUP_DIR/white_list_user.txt" #vide la white list

# sauvegarde 
./create_backup.sh "test1"

# check que la sauvegarde à fonctionner
if [ $? -eq 0 ]; then
  echo "test 5: NOK, la sauvegarde a fonctionnée ou elle ne devrait pas"
else
  echo "test 5: OK, la sauvegarde n'a pas fonctionnée comme convenue"
fi

cleaning "test1"
echo -e "--------------------------------------------\n"
#---------------------------------------------------------------

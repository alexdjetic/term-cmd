#!/bin/bash

# Taille de la clé RSA
key_size=2048

# Répertoire par défaut
default_dir="~/keys"
key_dir=""

# Préfixe par défaut
default_prefix="my_keys_"
prefix=""

generate() {
    # Génération de la clé privée
    openssl genpkey -algorithm RSA -out "$key_dir/${prefix}private.key" -pkeyopt rsa_keygen_bits:$key_size

    # Extraction de la clé publique à partir de la clé privée
    openssl rsa -pubout -in "$key_dir/${prefix}private.key" -out "$key_dir/${prefix}public.key"

    echo "Clés RSA générées avec succès dans $key_dir"
}

while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -d|--dir)
        key_dir="$2"
        shift
        ;;
        -f|--file)
        prefix="$2"
        shift
        ;;
        *)
        echo "Option non valide: $key"
        exit 1
        ;;
    esac
    shift
done

# Utiliser le répertoire par défaut s'il n'est pas spécifié
key_dir=${key_dir:-$default_dir}

# Vérifier si le répertoire par défaut existe, sinon le créer
if [[ ! -d "$key_dir" ]]; then
    mkdir -p "$key_dir"
fi

# Utiliser le préfixe par défaut s'il n'est pas spécifié
prefix=${prefix:-$default_prefix}

generate

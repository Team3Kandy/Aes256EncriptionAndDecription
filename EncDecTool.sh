#!/bin/bash
printhelp()
{
   cat << eof

   Usage:$0 [options]
   Choose one of the following:

     -e | --encrypt <filename> -k | --key <keyfile>      encrypts filename with keyfile.
     -d | --decrypt <folder>   -k | --key <keyfile>      decrypts filename with keyfile.
     -h | --help                                         show help menu
    TODO : add key
   Example: $0 -e test.txt -k key.key

eof
   exit 0
}

encrypt(){
    local filename=$(echo $1) # filename param
    local keyfile=$(echo $2)  # key file 
    openssl enc -aes-256-cbc -in $filename -out "encrypted" -kfile $keyfile -nosalt
    cat "encrypted" | xxd -l 16 -p
    # rm "encrypted"
    exit 0
}

decrypt(){
    local filename=$(echo $1) # filename param
    local keyfile=$(echo $2)  # key file 
    openssl enc -d -aes-256-cbc -in $filename -out "decrypted" -kfile $keyfile -nosalt
    cat "decrypted" | xxd -l 16 -p
    # rm "decrypted"a
    exit 0
}

addKeytoStore(){
    local keyStoreFile=$(echo $1) # key store file name
    local alias=$(echo $2) # key alias
    local key=$(echo $3)   # key
    local awkparam="'/$alias/'" 
    if [ -e "$keyStoreFile" ]; then
        local result=$(grep $alias $keyStoreFile)
        # echo $result
        if [ "$result" != "" ]; then
            echo "This alias already exist"
            exit 0
        fi

        echo "$alias $key" >> "./$keyStoreFile"
    else 
        echo "$alias $key" >> "./$keyStoreFile"
    fi 
    echo "Key succesfully added"
    exit 0
}

while test $# -ne 0; do
    
    case $1 in
        -h | --help)
            printhelp
            exit
            ;;
        -e | --encrypt)
            FILENAME=$2
            FLAG="e"
            shift
            ;;
        -d | --decrypt)
            FILENAME=$2
            FLAG="d"
            shift
            ;;
        -k | --key)
            KEY=$2
            shift
            ;;
        -a | --addkey)
            addKeytoStore "$2" "$3" "$4"
            shift
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            printhelp
            exit 1
            ;;
    esac
    shift
done

if [ "$KEY" == "" ]; then
   echo "parameter error"
   exit 0
fi

if [ "$FILENAME" == "" ]; then
    echo "Filename error"
    exit 0
fi

if [ "$FLAG" == "e" ]; then
    encrypt "$FILENAME" "$KEY"
    exit 0
fi

if [ "$FLAG" == "d" ]; then
    decrypt "$FILENAME" "$KEY"
    exit 0
fi

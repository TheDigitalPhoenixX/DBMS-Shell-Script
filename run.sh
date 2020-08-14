#!/bin/bash

DIR_DB_STORAGE="./DBStorage/"
TIMED_MSG_TIME=2

function timedError() {
    echo $1
    sleep $TIMED_MSG_TIME
    clear
}

function timedSuccess() {
    clear
    echo -e "\n\t$1\n"
    sleep $TIMED_MSG_TIME
    clear
}

function listDBs() {
    echo "+=================+"
    echo "|Existing DBs are:|"
    echo "+=================+"
    ls $DIR_DB_STORAGE
}

function checkIfDBsExist() {
    if test -z "$(ls $DIR_DB_STORAGE)"
    then
        timedError "You don't have any DBs yet!"
        return -1
    fi
    return 0
}

function confirmMenu() {
    select choice in "Confirm" "Cancel"
    do
        case $choice in
            "Confirm")
                return 0
                ;;
            "Cancel")
                return -1
                ;;
            *)
                echo "Invalid Option"
        esac
    done
}

function createTable() {
    echo "Kindly enter your Table name:"
    read tableName
    fileName="$DIR_DB_STORAGE$1/$tableName.csv"
    if test -f $fileName
    then
        timedError "A table named \"$tableName\" already exists."
    elif [[ $tableName =~ ^[a-zA-Z][a-zA-Z0-9]* ]]
    then
        timedSuccess "P.S. The first column will be your PK"
        echo -e "Now you are working with '$tableName' table\n"
        echo "Please enter number of columns: "
        read numberOfColumns
        while [[ ! $numberOfColumns =~ [0-9]+ ]]
        do
            echo "Invalid Number"
            read numberOfColumns
        done
        i=0
        while [ $numberOfColumns -gt $i ]
        do
            clear
            echo -e "Now you're settubg the names and datatypes of columns in '$tableName' table.\n"
            echo "Please enter the name of column $(($i+1)):"
            read columnName
            while [[ ! $columnName =~ [a-zA-Z]+ ]]
            do
                echo "Invalid String"
                read columnName
            done
            echo "What data type are you going to store in '$columnName' column?"
            select choice in "Integer" "String"
            do
                case $choice in
                    "Integer")
                        echo -n "$columnName/Integer," >> $fileName
                        break
                        ;;
                    "String")
                        echo -n "$columnName/String," >> $fileName
                        break
                        ;;
                    *)
                        echo "Invalid Option"
                esac
            done
            i=$(($i+1))
        done
        echo "" >> $fileName
        timedSuccess "Table \"$tableName\" was created successfully."
    else
        timedError "Invalid name.(Table name should start with a letter and contain only letters and numbers!!)"
    fi
}

function listTables() {
    echo "+====================+"
    echo "|Existing Tables are:|"
    echo "+====================+"
    ls $1 | cut -f 1 -d .
}

function checkIfTablesExist() {
    if test -z "$(ls $DIR_DB_STORAGE$1)"
    then
        timedError "You don't have any Tables yet!"
        return -1
    fi
    return 0
}

function deleteTable() {
    checkIfTablesExist $1
    if [ $? -eq 0 ]
    then
        listTables $DIR_DB_STORAGE$1
        echo "Kindly enter Table name to be DELETED"
        read tableName
        fileName="$DIR_DB_STORAGE$1/$tableName.csv"
        while [ ! -f $fileName ]
        do
            echo "'$tableName' table doesn't exist!"
            echo "Try Again"
            read tableName
        done
        clear
        echo "Do you want to Delete '$tableName' Table?"
        confirmMenu
        if [ $? -eq 0 ]
        then
            rm $fileName
            timedSuccess "\"$tableName\" table was deleted"
        fi
    fi
}

function dbMenu() {
    clear
    echo -e "Now you are working with '$1' DB\n"
    select option in "Create new Table" "Delete Table" "Insert into Table" "Modify a Table" "Display a Table" "List Existing Tables" "Back to main menu"
    do
        case $option in
            "Create new Table")
                createTable $1
                ;;
            "Delete Table")
                deleteTable $1
                ;;
            "Insert into Table")
                ;;
            "Modify a Table")
                ;;
            "Display a Table")
                ;;
            "List Existing Tables")
                listTables $DIR_DB_STORAGE$1
                echo "+=======================+"
                echo "|Press enter to continue|"
                echo "+=======================+"
                read
                ;;
            "Back to main menu")
                return
                ;;
        esac
        break
    done
    dbMenu $1
}

function mainMenu()  {
    clear
    mkdir $DIR_DB_STORAGE 2> /dev/null
    echo -e "Main Menu :\n"
    select option in "Create new DB" "Delete DB" "Open DB" "List existing DBs" "Exit"
    do
        case $option in
            "Create new DB")
                echo "Kindly Enter your new DB name:"
                read dbName
                if test -d $DIR_DB_STORAGE$dbName
                then
                    timedError "A DB named \"$dbName\" already exists."
                elif [[ $dbName =~ ^[a-zA-Z][a-zA-Z0-9]* ]]
                then
                    mkdir $DIR_DB_STORAGE$dbName
                    timedSuccess "DB: \"$dbName\" was created successfully."
                else
                    timedError "Invalid name.(DB name should start with a letter and contain only letters and numbers!!)"
                fi
                ;;
            "Delete DB")
                checkIfDBsExist
                if [ $? -eq 0 ]
                then
                    listDBs
                    echo "Kindly enter DB name to be DELETED"
                    read dbName
                    while [ ! -d $DIR_DB_STORAGE$dbName ]
                    do
                        echo "'$dbName' DB doesn't exist!"
                        echo "Try Again"
                        read dbName
                    done
                    clear
                    echo "Do you want to Delete '$dbName' DB?"
                    confirmMenu
                    if [ $? -eq 0 ]
                    then
                        rm -r $DIR_DB_STORAGE$dbName
                        timedSuccess "\"$dbName\" DB was deleted"
                    fi

                fi
                ;;
            "Open DB")
                checkIfDBsExist
                if [ $? -eq 0 ]
                then
                    listDBs
                    echo "Kindly enter DB name to be DELETED"
                    read dbName
                    while [ ! -d $DIR_DB_STORAGE$dbName ]
                    do
                        echo "'$dbName' DB doesn't exist!"
                        echo "Try Again"
                        read dbName
                    done
                    clear
                    dbMenu $dbName
                fi
                ;;
            "List existing DBs")
                listDBs
                echo "+=======================+"
                echo "|Press enter to continue|"
                echo "+=======================+"
                read
                ;;
            "Exit")
                exit
                ;;
            *)
                echo Try Again
        esac
        break
    done
    mainMenu
}

mainMenu
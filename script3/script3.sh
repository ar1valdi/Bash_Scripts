#!/bin/bash

in=""
empty=""
name=""
dir=""
youngerThan=""
olderThan=""
permissions=""
inside=""
option=0

while [ "$option" != "Wyjdz z programu" ]; do
    option=$(zenity --list --title "Find Your File" --text "Wybierz opcje wyszukiwania" --column "" "Nazwa pliku" "Lokalizacja pliku" "Plik mlodszy niz" "Plik starszy niz" "Uprawnienia pliku" "Zawartosc pliku" "Szukaj" "Wyjdz z programu" --height 400 --width 400)
    
    case $option in
        "Nazwa pliku") name=$(zenity --entry --title "Find Your File" --text "Podaj nazwe pliku: ");;
        "Lokalizacja pliku") dir=$(zenity --file-selection --directory --title "Find Your File" --filename "$dir" --text "Podaj sciezke do katalogu: ");;
        "Plik mlodszy niz") youngerThan=$(zenity --entry --title "Find Your File" --text "Podaj date: -  YYYY-MM-DD HH:MM:SS: ");;
        "Plik starszy niz") olderThan=$(zenity --entry --title "Find Your File" --text "Podaj date: - YYYY-MM-DD HH:MM:SS: ");;
        "Uprawnienia pliku") permissions=$(zenity --entry --title "Find Your File" --text "Podaj uprawnienia - format 777: ");;
        "Zawartosc pliku") inside=$(zenity --entry --title "Find Your File" --text "Podaj zawartosc: ");;
    esac
    
    # Search
    if [ "$option" == "Szukaj" ]; then
        criteria="find "
        if [ "$dir" != "" ]; then
            criteria="$criteria $dir -type f"
        else
            criteria="$criteria /home -type f"
        fi
        if [ "$name" != "" ]; then
            criteria="$criteria -name \"$name\""
        fi
        if [ "$youngerThan" != "" ]; then
            criteria="$criteria -not -newermt \"$youngerThan\""
        fi
        if [ "$olderThan" != "" ]; then
            criteria="$criteria -newermt \"$olderThan\""
        fi
        if [ "$permissions" != "" ]; then
            criteria="$criteria -perm $permissions"
        fi
        if [ "$inside" != "" ]; then
            criteria="$criteria -exec grep -l \"$inside\" {} \;"
        fi
        
        output=$(eval $criteria)
        zenity --info --title "Find Your File" --text "$output"
    fi
done

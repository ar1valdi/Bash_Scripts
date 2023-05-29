#!/bin/bash

# Author           : Jan Kaczerski ( jkaczerski@gmail.com )
# Created On       : 15.05.2023
# Last Modified By : Jan Kaczerski ( jkaczerski@gmail.com )
# Last Modified On : 15.05.2023
# Version          : 1.0
#
# Description      : 	- Simple hangman game. Application conatians menu with three options
#				- set difficulty (3, 5 or 7 lives)
#		     		- add new word to the database
#				- start the game
#				- user can move through menu with WSAD, and enter option with E
#		     	- Database is contatined in a 'words.txt' file, where each line represets new word to guess. Every word is converted to contain only small letters
#			- If file is not present, it will be created and default words (from defWords array) will be added		     	
#			- Game starts after submiting 'Play' button
#		    	- Entering wrong characters (eg. numbers, symbols) is blocked
#			- Big letters are converted into small letters in order to match the word
#			- Entering already guessed letter is blocked
#			- When player guesses the word or has no more tries, end screen is shown
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

# Def words if file does not exist
readonly defWords=("man" "mom" "dad" "cat" "dog" "cat" "flower" "motorcycle" "shape" "book")

# "defines"
readonly DEBUG_MODE=0

readonly WON=1
readonly LOST=2
readonly IN_GAME=0
readonly LEFT="LEFT"
readonly RIGHT="RIGHT"
readonly UP="UP"
readonly DOWN="DOWN"
readonly ENTER="ENTER"
readonly HELP_COMM="-h"
readonly AUTHOR_COMM="-v"

function drawLogo {	
	echo -e "\e[31m------------------------------ HANGMAN ------------------------------\e[0m"
	echo ""
	echo ""
}

# check if words.txt exists and if not, create with defWords loaded
function handleWordsFile {
	if [ ! -f words.txt ]; then
		touch words.txt
		local toLoad
		for toLoad in "${defWords[@]}"
		do
			echo "$toLoad" >> words.txt
		done
	fi
}

# load word from file
function loadWord {
	handleWordsFile	
	echo "$(sort -R words.txt | head -n 1)"
}

# echo ascii hangman drawing ($1 indicates game state)
function drawHangman {
    case $1 in
    	    0) echo "_________
|    |
|    
|   
|    
|   
|
L________" ;;
    1) echo "_________
|    |
|    O
|   
|    
|   
|
L________" ;;
    2) echo "_________
|    |
|    O
|   /
|    
|   
|
L________" ;;
    3) echo "_________
|    |
|    O
|   /|
|    
|   
|
L________" ;;
    4) echo "_________
|    |
|    O
|   /|\\
|    
|   
|
L________" ;;
    5) echo "_________
|    |
|    O
|   /|\\
|    |
|   
|
L________" ;;
    6) echo "_________
|    |
|    O
|   /|\\
|    |
|   / 
|
L________" ;;
    7) echo "_________
|    |
|    O
|   /|\\
|    |
|   / \\
|
L________" ;;
esac
}

# read and validate input inside menu
function readInputMenu {
	local input
	read -s -n 1 input
	while true; do
		local rightVal=1;
		case $input in
			'w') local action=$UP ;;
			's') local action=$DOWN ;;
			'a') local action=$LEFT ;;
			'd') local action=$RIGHT ;;
			'e') local action=$ENTER ;;
			*) read -s -n 1 input 
			   rightVal=0;;
		esac
		
		if [ $rightVal -eq 1 ]; then
			break;
		fi
	done
	
	echo "$action"
}

# change difficulty loop
function changeDiff {
	local innerAction=""
	while [[ $innerAction != $ENTER ]] 
	do
		clear
		printMenu $1
		echo ""
		echo "Change difficulty with A and D, confirm with E"
		
		# change difficulty with A and D
		innerAction=$(readInputMenu)
		case $innerAction in
			$LEFT) difficulty=$(($difficulty-1));;
			$RIGHT) difficulty=$(($difficulty+1));;
		esac
		
		# block going out of range
		if [ $difficulty -eq 0 ]; then
			difficulty=1
		elif [ $difficulty -eq 4 ]; then
			difficulty=3;
		fi
		
	done 
}

# enter and add new word to the database
function addWord {
	handleWordsFile		# ensure that words.txt is created
	local input=" "

	clear
	drawLogo
	echo "Enter new word:"
		
	# input valid word to be added (only alphabet letters)
	while [[ ! "$input" =~ ^[[:alpha:]]+$ ]];
	do
		read input
		clear
		drawLogo
		echo "You can only use letters"
		echo "Enter new word: "
	done

	local lowercase=$(echo "$input" | tr '[:upper:]' '[:lower:]')

	#check if entered word is already in file
	if ! grep -x -F -q "$lowercase" words.txt; then
		echo "$lowercase" >> words.txt 
	fi
}

# return word appropriate for difficulty number
function setDiffWord {
	case $1 in
	1) echo "Easy" ;;
	2) echo "Medium" ;;
	3) echo "Hard" ;;
	esac
}

# print main menu view
function printMenu {
	local difWord=$(setDiffWord $difficulty)
	drawLogo
	
	#-------------- Print menu with colored selected option
	
	# Difficulty
	if [ $1 -eq 1 ]; then 
		echo -e "\e[32m" 
		echo "Difficulty: $difWord"
		echo -e "\e[0m" 
	else
		echo "Difficulty: $difWord"
	fi

	# Add word
	if [ $1 -eq 2 ]; then 
		echo -e "\e[32m" 
		echo "Add word"
		echo -e "\e[0m" 
	else
		echo "Add word"
	fi

	# Add word
	if [ $1 -eq 3 ]; then 
		echo -e "\e[32m" 
		echo "Play"
		echo -e "\e[0m" 
	else
		echo "Play"
	fi
	
	#-------------------------------------------------------

	echo ""
	echo ""
	echo ""
	echo "Navigate with WSAD for directions and E for enter"
}

# run main menu
function mainMenu {
	local start=0
	local option=1
	
	while [ $start -eq 0 ]
	do
		clear
		printMenu $option
		
		# select action
		local action=$(readInputMenu);
		case $action in
			$UP) option=$((option-1)) ;;
			$DOWN) option=$((option+1)) ;;
			$ENTER) 
				case $option in
				1) changeDiff $option;;
				2) addWord;;
				3) start=1;;
				esac
			;;
		esac
		
		# block going out of bounds
		if [ $option -eq 0 ]; then
			option=1
		elif [ $option -eq 4 ]; then
			option=3
		fi
	done
}

# returns number of max guesses based od difficulty
function calcMaxGuesses {
	case $difficulty in
		1) echo "7" ;;
		2) echo "5" ;;
		3) echo "3" ;;
	esac
}

# check if entered letter was already guessed or is in hidden word
function checkLetter {
	local letter=$(echo "$1" | tr '[:upper:]' '[:lower:]')	# cast all upper letters to low letters
	local i
	local c
	
	# check if letter was guessed in correct guesses
	for c in "${guessedLetters[@]}"
		do
			if [[ "$c" == "$letter" ]]; then
				echo "You already guessed this letter"
				sleep 1
				return
			fi
		done
	
	# check if letter is in the hidden word
	for (( i=0; i<${#word}; i++ )); do
		if [[ "${word:$i:1}" == "$letter" ]]; then
			guessedLetters+=($letter)
			return
		fi
	done
	
	# check if letter was guessed in wrong guesses
	for c in "${guessedWrongLetters[@]}"
	do
		if [[ "$c" == "$letter" ]]; then
			echo "You already guessed this letter"
			sleep 1
			return
		fi
	done
	
	# if not returned (new wrong letter), add it to table
	(( wrongGuesses++ ))
	guessedWrongLetters+=($letter)
}

# draw 'you lost' view
function drawLost {
	echo -e "\e[31m"
	echo "You Lost!"
	echo "The word was: $word"
	echo ""
	drawHangman 7
	echo -e "\e[0m"
}

# draw 'you won' view
function drawWon {
	echo -e "\e[32m"
	echo "You Won!"
	echo "The word was: $word"
	echo ""
	drawHangman $(($wrongGuesses + 7 - $maxGuesses))
	echo -e "\e[0m"
}

# setup mandatory variables
function setupGame {
	word=$(loadWord)
	guessedLetters=()
	guessedWrongLetters=()
	maxGuesses=$(calcMaxGuesses)
	wrongGuesses=0
	leftLetters=${#word}
}

# draw ingame view
function drawBoard {
	# top string rows
	local difWord=$(setDiffWord $difficulty)
	echo "Difficulty: $difWord"
	echo "$maxGuesses"
	local leftGuesses=$(($maxGuesses - $wrongGuesses))
	echo "Tries left: $leftGuesses"
	echo ""
	
	# hangman
	drawHangman $(($wrongGuesses + 7 - $maxGuesses))
	
	# hidden word with some letters shown
	local isFound=0
	echo ""
	leftLetters=0
	
	for ((i=0; i < ${#word}; i++ )); do
		isFound=0
		local letter
		for letter in "${guessedLetters[@]}"; do
			if [[ "$letter" == "${word:i:1}" ]]; then
				echo -n "$letter"
				isFound=1
				break;
			fi
		done
		if [[ isFound -eq 0 ]]; then
			echo -n '_'
			(( leftLetters++ ))
		fi
	done
	
	echo ""
	echo ""
	
	# wrong guesses list
	echo "Wrong guesses: "
	echo "${guessedWrongLetters[@]}"
	
	echo ""
	echo ""
}

# main game loop
function runGame {
	local result="$IN_GAME"
	
	while [ "$result" == "$IN_GAME" ]; 
	do
		clear
		
		#debug helper
		if [[ $DEBUG_MODE -eq 1 ]]; then
			echo "---DEBUG---"
			echo "hidden word  : $word"
			echo "left letters : $leftLetters"
			echo "wrong guesses: $wrongGuesses"
			echo "max guesses  : $maxGuesses"
			echo "-----------"
		fi
		
		drawLogo
		drawBoard
		
		# check if won
		if [ $leftLetters -eq 0 ]; then
			result="$WON"
			break
		fi
		
		# read guessed letter
		echo -n "Guess a letter: "
		
		local input='1'
		read input
		if [[ ! "$input" =~ ^[[:alpha:]]$ ]]; then
			continue;
		fi
		
		checkLetter $input
		
		# check if lost
		if [ $wrongGuesses -eq $maxGuesses ]; then
			result="$LOST"
		fi
	done
	
	# draw endscreen
	clear
	drawLogo
	if [ "$result" == "$WON" ]; then
		drawWon
	elif [ "$result" == "$LOST" ]; then
		drawLost
	fi
}

# main entry function
function main {
	difficulty=2
	clear	
	
	# run main menu
	mainMenu

	#load word to guess, set nessesery variables and tables for game to work properlly
	clear
	setupGame 

	# run main loop
	runGame
}

# -help command
function helpComm {
	clear
	echo -e "HANGMAN HELP
Point of the game is to guess the hidden word. To do that, enter letter that you want to guess into console. If you success, you win, if you run out of tries, you lose. 
    	
You can play in three different difficulties, in which number of accatable wrong guesses varies.
Easy - 3 tries
Medium - 5 tries
Hard - 7 tries
    		
You can set difficulty level in the menu, where you can also add new word to word database.
    	
Word database is inside the words.txt file. If file is not found, file will be created and small amount of words will be added."
	exit 0
}

# info about author command
function authorComm { 
    clear
    echo -e "Author: Jan Kaczerski (jkaczerski@gmail.com)
Version: 1.0 (primary)"
    exit 0
}



if [[ $1 == "$HELP_COMM" ]]; then
	helpComm
fi

if [[ $1 == "$AUTHOR_COMM" ]]; then
	authorComm
fi
main

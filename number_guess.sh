#!/bin/bash
# This script generates a random number and asks the user to guess it. The score is saved in the number_guess db.
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$((1 + $RANDOM % 999))
# echo $RANDOM_NUMBER

echo -e "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM scores WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO scores(username, games_played, best_game) VALUES('$USERNAME', 0, -1)")
  USER_ID=$($PSQL "SELECT user_id FROM scores WHERE username='$USERNAME'")
  GAMES_PLAYED=0
  BEST_GAME=-1
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  GET_USER=$($PSQL "SELECT games_played, best_game FROM scores WHERE user_id=$USER_ID")
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< $GET_USER
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


echo -e "\nGuess the secret number between 1 and 1000:"
read NUMBER_INPUT
CURRENT_GUESSES=1
until [[ $NUMBER_INPUT -eq $RANDOM_NUMBER ]]
do
  until [[ $NUMBER_INPUT =~ ^[1-9][0-9]*$ ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read NUMBER_INPUT
    ((CURRENT_GUESSES++))
  done

  if [[ $NUMBER_INPUT -gt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    read NUMBER_INPUT
    ((CURRENT_GUESSES++))
  else
    echo -e "\nIt's higher than that, guess again:"
    read NUMBER_INPUT
    ((CURRENT_GUESSES++))
  fi
done

((GAMES_PLAYED++))
if [[ $BEST_GAME -lt 0 || $CURRENT_GUESSES -lt $BEST_GAME ]]
then
  BEST_GAME=$CURRENT_GUESSES
fi
UPDATE_SCORE_RESULTS=$($PSQL "UPDATE scores SET games_played=$GAMES_PLAYED, best_game=$BEST_GAME WHERE user_id=$USER_ID")

echo -e "\nYou guessed it in $CURRENT_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

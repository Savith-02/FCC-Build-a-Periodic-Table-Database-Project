#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c " 

INVALID_INPUT() {
  echo "I could not find that element in the database."
  exit
}
VALID_INPUT() {
  NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number='$1'" | sed -r 's/^ *| *$//g')
  SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number='$1'" | sed -r 's/^ *| *$//g')
  Bpt=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number='$1'" | sed -r 's/^ *| *$//g')
  FORMATTED_Bpt=$(echo $Bpt | sed -r 's/^ *| *$//g')
  Mpt=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number='$1'" | sed -r 's/^ *| *$//g')
  M=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number='$1'" | sed -r 's/^ *| *$//g')
  TYPE=$($PSQL "SELECT type FROM types FULL JOIN properties USING(type_id) INNER JOIN elements USING(atomic_number) WHERE atomic_number=$1" | sed -r 's/^ *| *$//g')

  echo "The element with atomic number $1 is $NAME ($SYMBOL). It's a $TYPE, with a mass of $M amu. $NAME has a melting point of $Mpt celsius and a boiling point of $Bpt celsius."
}

# Check if an input is given
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  # Check if input is a number
  if [[ $1 =~ ^[0-9]{1,2}$ ]]
  then
    ATOMIC_NUMBER_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    # Check if entered number is a valid atomic number 
    if [[ -z $ATOMIC_NUMBER_RESULT ]]
    then
      INVALID_INPUT
    fi
    VALID_INPUT $ATOMIC_NUMBER_RESULT

  # Check if input is a symbol
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
    SYMBOL_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
    # Check if entered symbol is valid
    if [[ -z SYMBOL_RESULT ]]
    then 
      INVALID_INPUT
    fi
    VALID_INPUT $SYMBOL_RESULT

  #Check if input is a name
  else
    NAME_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
    # Check if entered symbol is valid
    if [[ -z $NAME_RESULT ]]
    then 
      INVALID_INPUT
    fi
    VALID_INPUT $NAME_RESULT
  fi

fi

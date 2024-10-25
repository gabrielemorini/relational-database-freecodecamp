#!/bin/bash

# If the first argument is "test", use the test database
if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Clean the 'teams' and 'games' tables (reset the database)
echo $($PSQL "TRUNCATE teams, games")

# Read the CSV file line by line
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  # Skip the header row (if it exists) that starts with 'winner'
  if [[ $WINNER != "winner" ]]; then

    # === HANDLING WINNER TEAM ===
    # Get the winner team's ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # If the winner team doesn't exist in the database
    if [[ -z $WINNER_ID ]]; then
      # Insert the new winner team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

      # Check if the insertion was successful
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted winner team into the database: $WINNER"
      fi

      # Retrieve the new winner team's ID
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # === HANDLING OPPONENT TEAM ===
    # Get the opponent team's ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If the opponent team doesn't exist in the database
    if [[ -z $OPPONENT_ID ]]; then
      # Insert the new opponent team
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      # Check if the insertion was successful
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]; then
        echo "Inserted opponent team into the database: $OPPONENT"
      fi

      # Retrieve the new opponent team's ID
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # === INSERTING GAME ===
    # Insert the game into the 'games' database
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
                                VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

    # Check if the insertion was successful
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]; then
      echo "Inserted game into the database: $WINNER vs $OPPONENT ($YEAR, $ROUND)"
    fi
  fi
done

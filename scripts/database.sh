#!/bin/bash

# create database
psql --username=freecodecamp --dbname=postgres -c "CREATE DATABASE worldcup;"

# connect database
PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"

# Create teams table
echo $($PSQL "CREATE TABLE teams(
 team_id SERIAL PRIMARY KEY NOT NULL,
 name VARCHAR(85) UNIQUE NOT NULL
)")

# Create games table
echo $($PSQL "CREATE TABLE games(
 game_id SERIAL PRIMARY KEY NOT NULL,
 year INT NOT NULL,
 round VARCHAR (55) NOT NULL,
 winner_goals INT NOT NULL,
 opponent_goals INT NOT NULL,
 winner_id INT REFERENCES teams (team_id) ON DELETE CASCADE NOT NULL,
 opponent_id INT REFERENCES teams (team_id) ON DELETE CASCADE NOT NULL
)") 

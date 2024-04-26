#!/bin/bash

# Installation script to dynamically run all .sh script files from the dotfiles repository

echo "Starting the dynamic installation of dotfiles scripts..."

# Change directory to the repository location (modify this path as necessary)
cd ~/.dotfiles 

# Find and execute each .sh script
find . -name "*.sh" -exec chmod +x {} \; -exec echo "Running {}..." \; -exec {} \;

echo "Dynamic installation of dotfiles scripts completed."

# Ensure the script ends with a new line

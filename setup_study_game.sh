#!/bin/bash

# Create main project directory
mkdir -p study-games

# Create data subdirectories
mkdir -p study-games/data/{questions,flashcards,definitions}
mkdir -p study-games/saves

# Create main script and make it executable
touch study-games/study_games.sh
chmod +x study-games/study_games.sh

# Create JSON files for each category
categories=("it" "project_management" "software_dev")

for category in "${categories[@]}"; do
    # Create question files
    touch "study-games/data/questions/${category}_questions.json"
    # Create flashcard files
    touch "study-games/data/flashcards/${category}_cards.json"
    # Create definition files
    touch "study-games/data/definitions/${category}_terms.json"
done

# Initialize each JSON file with empty structure
for dir in questions flashcards definitions; do
    for file in study-games/data/$dir/*.json; do
        case $dir in
            "questions")
                echo '{"questions": []}' > "$file"
                ;;
            "flashcards")
                echo '{"cards": []}' > "$file"
                ;;
            "definitions")
                echo '{"terms": []}' > "$file"
                ;;
        esac
    done
done

# Create placeholder for save file
touch study-games/saves/last_session.save

echo "Directory structure created successfully!"
echo "Project structure:"
tree study-games


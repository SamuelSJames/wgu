# Quiz Game with random question selection
play_quiz() {
    local category=$1
    local start_position=${2:-0}
    local questions_file="$DATA_DIR/questions/${category}_questions.json"
    local questions_per_quiz=15
    
    # Get total number of questions available
    total_questions=$(jq '.questions | length' "$questions_file")
    
    # Create array of random question indices
    random_indices=($(seq 0 $((total_questions-1)) | shuf | head -n $questions_per_quiz))
    
    for ((i=0; i<questions_per_quiz; i++)); do
        question_index=${random_indices[$i]}
        show_header "Quiz Game - Question $((i+1))/$questions_per_quiz"
        
        # Get question data
        question=$(jq -r ".questions[$question_index].question" "$questions_file")
        correct_answer=$(jq -r ".questions[$question_index].correct_answer" "$questions_file")
        
        echo -e "\n${BOLD}Question $((i+1)):${NC} $question"
        
        # Display options
        options=($(jq -r ".questions[$question_index].options[]" "$questions_file"))
        for ((j=0; j<${#options[@]}; j++)); do
            echo "$((j+1)). ${options[$j]}"
        done
        
        echo -e "\n(P)ause game and save progress"
        read -p "Your answer (1-4 or P): " answer
        
        if [[ $answer =~ ^[Pp]$ ]]; then
            # Save progress including random indices array
            save_progress "quiz" "$category" "$i" "${random_indices[*]}"
            return
        fi
        
        if [ "${options[$((answer-1))]}" = "$correct_answer" ]; then
            echo -e "${GREEN}Correct!${NC}"
            ((CURRENT_SCORE+=4))
        else
            echo -e "${RED}Incorrect. The correct answer was: $correct_answer${NC}"
        fi
        
        read -p "Press Enter to continue..."
    done
    
    # Show final score
    echo -e "\n${GREEN}Quiz Complete!${NC}"
    echo "Your score: $CURRENT_SCORE out of $((questions_per_quiz * 4))"
    read -p "Press Enter to return to main menu..."
}

# Updated save_progress function to handle random indices
save_progress() {
    local game_type=$1
    local category=$2
    local current_position=$3
    local random_indices=$4
    
    cat > "$SAVE_FILE" << EOF
GAME_TYPE=$game_type
CATEGORY=$category
POSITION=$current_position
SCORE=$CURRENT_SCORE
TIMESTAMP=$(date +%s)
RANDOM_INDICES=($random_indices)
EOF
    echo -e "\n${GREEN}Progress saved!${NC}"
}

# Updated load_progress function
load_progress() {
    if [ -f "$SAVE_FILE" ]; then
        source "$SAVE_FILE"
        local saved_time=$(date -d @$TIMESTAMP "+%Y-%m-%d %H:%M:%S")
        echo -e "${YELLOW}Found saved game from: $saved_time${NC}"
        echo -e "Game: $GAME_TYPE"
        echo -e "Category: $CATEGORY"
        echo -e "Score: $SCORE\n"
        
        read -p "Would you like to resume? (y/n): " resume
        if [[ $resume =~ ^[Yy]$ ]]; then
            CURRENT_SCORE=$SCORE
            case $GAME_TYPE in
                quiz) play_quiz "$CATEGORY" "$POSITION" "${RANDOM_INDICES[*]}";;
                flashcards) play_flashcards "$CATEGORY" "$POSITION";;
                hangman) play_hangman "$CATEGORY";;
            esac
        fi
    else
        echo "No saved progress found."
    fi
}

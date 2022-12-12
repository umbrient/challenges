require 'pry-byebug'

module Utility

    @@included_numbers = ""
    @@vetted_all = false

    def self.reset
        @@vetted_all = false
        @@included_numbers = ""
    end

    def self.colours
        ["Red","Green","Yellow","Blue","Purple"]
    end

    def self.generate_a_guess(guesses)
        guess = ''
    
        # Find which number is missing in 3 guesses max.
        guess = find_included_numbers(guesses) unless @@vetted_all
        
        if @@vetted_all && @@included_numbers != ""
            loop do
                guess = @@included_numbers.split("").shuffle.join

                # Covers things like 1234 and 4321, since it's a human playing.
                if guesses.keys.none? {|k| k == guess.split("").sort.join }
                    guess = guess.split("").sort.join
                elsif guesses.keys.none? {|k| k == guess.split("").sort.reverse.join}
                    guess = guess.split("").sort.reverse.join
                end

                break if guesses.keys.none? {|k| k == guess}
            end 
        end

        puts "\n\nIncluded Numbers: #{@@included_numbers == "" ? "I don't know yet." : @@included_numbers}"
        puts "Failed Combinations: (#{guesses.keys.join(", ")})"
        puts "Trying: #{guess}"


        return guess 
    end


    def self.find_included_numbers(guesses) 
        
        return guesses.length.to_s*4 if guesses.length < 5 && @@included_numbers.length < 4


        if @@included_numbers == ""
            guesses.each do |guess, feedback|
                occurrences = feedback.scan("✓").count
                @@included_numbers << guess[0]*occurrences if occurrences > 0
                break if @@included_numbers.length == 4
            end
        end    
        

        
        @@vetted_all = true 

    end

    def self.generate_colours
        ((0..4).to_a * 4).sample(4).join.to_s
    end

end

module Interface

    def self.say(msg)
        puts "\n\n#{msg}\n\n"
    end

    def self.greet
        say "Welcome to Mastermind."
    end

    def self.title(title)
        puts "-------------------------- #{title} --------------------------"
    end

    def self.instructions
        title "instructions"
        puts "1) Be the Guesser or the Chooser"
        puts "2) The Chooser picks 4 colours in a specific order."
        puts "3) The Guesser has 12 guesses to guessf the colours in order."
        puts "4) There are only 5 possible colours to play with."
        puts "5) The game will give some feedback after each guess."
        puts "6) The feedback will show as ✗ (wrong) or • (matching colour but not position) or ✓ (matching colour and position)"
        puts "7) The Guesser should use this feedback to improve their guesses."
    end

    def self.await_enter(txt)
        say txt
        gets.strip
    end

    def self.are_you_ready
        await_enter "Are you ready? (y/n)"
    end

    def self.ask_role 
        await_enter "Would you like to be the guesser? (y/n)"
    end

    def self.role(bool)
        bool ? 'guesser' : 'chooser'
    end

    def self.ask_colours
        say "These are the colours you may choose from."
        colours
        await_enter "Using the numbers next to the colours, enter a valid 4-digit combination (e.g. 1111 or 1453)"
    end

    def self.colours
        # list all colours with their index and ask user to choose 4 like 1424 or 2856 (blue green red etc.)
        # show examples :), and yes, 1111 is a valid selection
        Utility.colours.each_with_index { |c, index| puts "#{index} - #{c}" }
    end

    def self.ask_guess(guesses, feedback)
        say "You have #{guesses} guesses left."
        colours
        await_enter "Take a guess (e.g. 0243 or 3123 or 1111 etc.) :"
    end

    def self.feedback(feedback)
        feedback.each_with_index do |f, i|
            say "Guess #{i+1}/12: #{f[0]} - Feedback: #{f[1]}"
        end
    end

    def self.reveal_colours(colours)
        say "The colours were (in order): #{colours.split("").map{|n| Utility.colours[n.to_i].capitalize }.join(", ")} (#{colours})"
    end

    def self.game_over_win(guesses, colours)
        title "Congratulations"
        say "You cracked the game in #{guesses.length} guesses!"
        reveal_colours colours
    end

    def self.game_over_loss(guesses, colours)
        title "Game over!"
        say "Unfortunately, you are out of guesses and did not manage to guess the correct colours!"
        reveal_colours colours
    end
end

module Mastermind
    
    def self.start
        @role = ''
        @max_guesses = 12
        @guesses = {}
        @colours = ''
        Interface.greet
        Interface.instructions
        Utility.reset
        
        ready = ''
        loop do 
            ready = Interface.are_you_ready.downcase
            break if ['y','n'].include? ready
        end

        begin_game if ready == 'y' 
    end
    
    def self.guesser?
        @role
    end

    def self.begin_game 
        ask_role
        process_colour_generation
        begin_game_loop
    end

    def self.begin_game_loop
        guess_loop
    end

    def self.guess_loop 
        loop do 
            break if game_over?
            guess = guesser? ? Interface.ask_guess((@max_guesses - @guesses.count), @guesses) : get_computer_guess
            process_guess(guess) if valid_guess?(guess)
            give_feedback if guesser?
        end
        give_feedback unless guesser?
        process_game_over
    end

    def self.give_feedback
        Interface.feedback(@guesses)
    end

    def self.process_game_over 
        if guessed_correctly?
            
            Interface.game_over_win(@guesses, @colours)

        elsif out_of_guesses?

            Interface.game_over_loss(@guesses, @colours)

        end

        restart = ''
        loop do
            restart = Interface.await_enter "Would you like to restart? (y/n)"
            break if ['y', 'n'].include? restart.strip.downcase
        end
        
        if restart == 'y'
            puts `clear`
            start
        else 
            Interface.title "Cya later, alligator!"
        end
    end

    def self.game_over?
        out_of_guesses? || guessed_correctly?
    end

    def self.out_of_guesses?
        @guesses.length == 12 && !@guesses.keys.include?(@colours)
    end

    def self.guessed_correctly?
        @guesses.keys.include? @colours
    end 

    def self.already_processed?(num, processed_numbers, guess)
        ocurrences_match = processed_numbers.join.to_s.scan(/#{num}/).count == @colours.scan(/#{num}/).count
        guesses_match = guess.scan(/#{num}/).count == processed_numbers.join.to_s.scan(/#{num}/).count
        ocurrences_match || guesses_match
    end

    def self.process_guess(guess)
        hint = ""

        processed_numbers = []
        # Search for perfect match
        guess.split("").each_with_index do |n, index|
            if @colours.split("")[index] == guess[index]
                unless already_processed?(n, processed_numbers, guess)
                    hint << "✓"
                    processed_numbers << n 
                end
            end
        end

        # Search for colour match
        unless hint.length == 4
            guess.split("").each_with_index do |n, index|
                unless already_processed?(n, processed_numbers, guess)
                    hint << "•" if @colours.include?(n) && hint.length < 4
                    processed_numbers << n
                end
            end
        end

        unless hint.length == 4
            hint << "✗"*(4-hint.length)
        end

        @guesses[guess] = hint
    end

    def self.get_computer_guess
        Utility.generate_a_guess(@guesses)
    end

    def self.process_colour_generation
        @colours = guesser? ? Utility.generate_colours : user_pick_colours
    end

    def self.user_pick_colours
        pick = ''
        loop do
            pick = Interface.ask_colours
            break if valid_guess?(pick)
        end
        return pick
    end

    def self.valid_guess?(guess)
        guess.length == 4 && guess.split("").reject { |c| c.to_i < 0 || c.to_i > 4}.length == 4
    end

    def self.ask_role
        Interface.title "let's begin"
        
        loop do 
            @role = Interface.ask_role.downcase
            break if ['y','n'].include? @role
        end
        @role = @role == 'y'
    end

end


Mastermind.start
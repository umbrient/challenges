require 'pry-byebug'

class Board  
    def initialize
        @map = "123456789"
    end

    def get 
        str = '|'
        @map.split("").each_with_index do |n, index| 
            str += " #{n} |"
            str += "\n-------------\n|" if index == 2 || index == 5
        end

        str
    end

    def available_spaces
        @map.split("").reject{ |s| ['X', 'O'].include? s }
    end

    def mark(spot, marker) 
        @map.sub! spot, marker
    end

    def full? 
        @map.scan(/\d/).count == 0
    end

    def pattern_found?(markers)
        left_right?(markers) || top_down?(markers) || across?(markers)   
    end

    def pattern_matches?(indices, markers) 
        match = false
        markers.each do |m|
            match = (m*3).to_s.upcase == indices.map { |i| @map[i] }.join.to_s.upcase
            break if match
        end
        return match
    end

    def left_right?(markers)
        pattern_matches?([0,1,2], markers) ||
        pattern_matches?([3,4,5], markers) ||
        pattern_matches?([6,7,8], markers)
    end

    def top_down?(markers)
        pattern_matches?([0,3,6], markers) || pattern_matches?([1,4,7], markers) || pattern_matches?([2,5,8], markers) 
    end

    def across?(markers)
        pattern_matches?([0,4,8], markers) || pattern_matches?([2,4,6], markers)
    end



end

module Announcer

    def self.wrong_spot(spot)
        puts "#{spot.strip} is an invalid selection."
    end

    def self.draw 
        puts "Draw!"
    end 

    def self.winner(player)
        puts "\nGame over! #{player} has won the game!"
    end

    def self.game_over 
        puts "\n----------------------- GAME OVER -----------------------\n\n\n"
    end

    def self.welcome
        puts "Welcome to TicTacToe."
    end

    def self.ask_mode
        print "Would you like to vs. Computer? (y/n): "
    end
    
    def self.start_game
        puts "----------------------- BEGIN -----------------------\n\n\n"
    end

end 

class Game
    
    extend Announcer 

    attr_accessor :mode, :board

    # random boolean to initially choose who goes first 
    def initialize(board = nil)
        @mode = mode
        @board = board ||= Board.new 
        @whose_turn = ''
        @marker_1 = 'X'
        @marker_2 = 'O'
        @player = ''
    end

    def begin 
        greet_player
        ask_mode
        start_game
    end

    def greet_player
        Announcer.welcome
    end

    def ask_mode
        choice = ''
        loop do 
            Announcer.ask_mode
            choice = gets.strip.downcase
            break if ['y', 'n'].include? choice 
        end

        @mode = 'computer' if choice == 'y'
    end

    def start_game 
        Announcer.start_game
        instruct_chosen_player_to_start

        until @board.full? 
            puts "\n\n" 
            puts @board.get
            chosen_spot = ''
            loop do
                print "\n\nPick a number (#{@whose_turn}): "    
                
                if against_computer? && !players_turn?
                    chosen_spot = generate_computer_move
                else 
                    chosen_spot = gets.strip.to_s
                end

                break if valid_move?(chosen_spot)
            end

            @board.mark(chosen_spot, @whose_turn)

            if game_over? 
                break 
            end

            switch_player
        end
    end

    def generate_computer_move
        @board.available_spaces.shuffle.first
    end    

    def players_turn?
        @whose_turn == @player
    end

    def game_over?
        found = @board.pattern_found?(['X', 'O'])
        
        if @board.full? || found
            Announcer.game_over
            if @board.full? && !found
                Announcer.draw
            else
                puts @board.get
                announce_winner(@whose_turn)
            end
            return true
        end

        return false

    end

    def announce_winner(winner)
        Announcer.winner(winner)
    end

    def valid_move?(chosen_spot)
        if @board.available_spaces.length > 0 && !@board.available_spaces.include?(chosen_spot)
            Announcer.wrong_spot(chosen_spot)
            return false
        end
        return true 
    end


    def random_player
        instance_variable_get("@marker_#{[1, 2].shuffle.first}")
    end

    def switch_player 
        @whose_turn = @whose_turn == @marker_1 ? @marker_2 : @marker_1
    end

    def against_computer?
        @mode == 'computer'
    end

    def instruct_chosen_player_to_start
        @whose_turn = random_player
        @player = @whose_turn.dup

        puts "It looks like '#{@whose_turn}' will be going first!\n\n"
    end
end


# g = Game.new
# g = g.begin

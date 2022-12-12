require 'pry-byebug'
require 'colorize'


class Game 

    attr_accessor :board

    def initialize 
        @player_one = ''
        @player_two = ''
        @player_one_coin = 'º'
        @player_two_coin = '•'
        @board = new_board
        @current_player = ''
        @winner_coords = []
        @latest_coords = []
    end

    def get_input(msg, allowed_inputs)
        input = ''
        loop do 
            puts msg
            input = gets.chomp

            if allowed_inputs.is_a? Array 
                break if allowed_inputs.map(&:to_s).include? input.downcase.to_s
            elsif allowed_inputs.is_a? Regexp
                break if input.match? allowed_inputs
            end 
        end
        return input 
    end

    def get_coin 
        @current_player == @player_one ? @player_one_coin : @player_two_coin
    end

    def new_board
        @board = [
            ['-','-','-','-','-','-','-'],
            ['-','-','-','-','-','-','-'],
            ['-','-','-','-','-','-','-'],
            ['-','-','-','-','-','-','-'],
            ['-','-','-','-','-','-','-'],
            ['-','-','-','-','-','-','-'],
        ]
    end

    def run 
        greet
        rules
        exit unless do_begin? == 'y'
        pick_names
        play_the_game
    end

    def greet 
        puts "Welcome to Connect Four"
    end

    def rules 
        puts "\nRules:\n\n"
        puts "• Below is the game's grid:\n\n"
        puts show_board
        puts "\n• Each of the numbers at the top of the grid represents the column below it."
        puts "• On every turn, you will be prompted to input a number from 0-6 to indicate which column you want to put a coin into."
        puts "• Your coin will be dropped into the selected column, stacking on top of any other coins that are already in the column."
        puts "• The goal of the game is to get 4 coins in a row in any of the following directions:"
        puts "• A horizontal row ( ── ), a vertical row ( │ ), or a diagonal ( ╱ or ╲ ) one."
        puts "• This is a 2-player game. So, try to get 4 coins in a row while preventing your opponent from doing so first!"
    end

    def do_begin? 
        return get_input("\nAre you ready to begin? (y/n)", ['y','n'])
    end

    def pick_names
        @player_one = get_input("\nPlayer 1, choose a unique name (1-7 alphanumeric characters)", /[A-Za-z0-9]{1,7}$/)
        puts "\nHi, #{@player_one}! Your coin will be #{@player_one_coin}"
        
        loop do
            @player_two = get_input("\nPlayer 2, choose a unique name (1-7 alphanumeric characters)", /[A-Za-z0-9]{1,7}$/)
            break if @player_two != @player_one
        end 
        
        puts "\nHello, #{@player_two}! Your coin will be #{@player_two_coin}"
    end

    def clear 
        puts "\e[H\e[2J"
    end

    def play_the_game
        @current_player = random_player

        loop do 
            clear
            show_board
            process_coin_placement
            if match_found?
                winner 
                break
            end
            switch_player
        end
    end

    def process_coin_placement
        loop do 
            column = pick_a_column
            result = place_coin(get_coin, column.to_i)
            if result 
                break
            else 
                puts "\nColumn '#{column}' seems to be full, #{@current_player}. Pick another one."
            end
        end 
    end

    def pick_a_column
        get_input("\n#{@current_player}, pick a column to put a coin into.", (0..6).to_a)
    end

    def winner
        show_board
        puts "Game over! #{@current_player} wins this one!"
    end

    def match_found?
        found = false
        %w(vertical horizontal diag_rtl diag_ltr).each do |type|
            found = (send(type + "_match?") rescue false) 
            if found 
                break 
            else 
                @winner_coords = []
            end 
        end
        return found
    end

    def vertical_match?
        counter = 0
        (0..6).to_a.each do |n|
            break if counter >= 4
            counter = 0
            @board.each_with_index do |x, row|
                if @board[row][n] == get_coin
                    counter += 1 
                    @winner_coords << [row, n]
                    return true if counter == 4
                else 
                    counter = 0
                    @winner_coords = []
                end
            end
        end
        return counter >= 4
    end

    def horizontal_match?
        counter = 0
        @board.each_with_index do |x, row|
            break if counter >= 4
            counter = 0
            (0..6).to_a.each do |col|
                cell = @board[row][col] rescue 0
                if cell == get_coin
                    counter += 1
                    @winner_coords << [row,col]
                    break if counter >= 4
                else
                    @winner_coords = []
                    counter = 0
                end
            end
        end
        return counter >= 4
    end

    def diag_rtl_match?
        counter = 0
        @board.length.times do |row| 
            break if counter >= 4
            (0..6).to_a.reverse.each do |col| 
                cell = @board[row][col] rescue 0
                if cell == get_coin 
                    @winner_coords << [row, col]
                    counter += 1
                    break if counter >= 4
                    # puts "rtl counter is #{counter} because of #{row},#{col} for #{get_coin}"
                    if (@board[row+1][col-1] rescue 0) == get_coin
                        row += 1 
                    else 
                        # puts "rtl no hope on next one cus #{row+1},#{col-1} is #{@board[row+1][col+1]} so resetting to 0"
                        counter = 0
                        @winner_coords = []
                    end

                else 
                    counter = 0
                    @winner_coords = []
                end
            end
        end
        return counter >= 4
    end

    def diag_ltr_match?
        counter = 0
        @board.length.times do |row| 
            break if counter >= 4
            (0..6).to_a.each do |col| 
                cell = @board[row][col] rescue 0
                if cell == get_coin 
                    @winner_coords << [row, col]
                    counter += 1
                    break if counter >= 4
                    if (@board[row+1][col+1] rescue 0) == get_coin
                        row += 1 
                    else 
                        counter = 0
                        @winner_coords = []
                    end
                else 
                    counter = 0
                    @winner_coords = []
                end
            end
        end
        return counter >= 4
    end

    def place_coin(coin, column)
        placed = false 
        @board.reverse.each_with_index do |row, row_index|
            if row[column] == '-'
                row[column] = get_coin
                placed = true 
                @latest_coords = [@board.index(row), column]
                break
            end 
        end
        return placed
    end

    def random_player
        instance_variable_get("@player_" + ["one", "two"].sample)
    end

    def switch_player
        @current_player = @current_player == @player_one ? @player_two : @player_one
    end

    def show_board
        display      = ''
        columns      = "    0   1   2   3   4   5   6  "
        line         = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
        body         = ''

        @board.length.times do |row_index|
            body += "#{row_index} │ "
            body += @board[row_index].each_with_index.map do |s, col_index|    
                str = if @latest_coords == [row_index, col_index] && @winner_coords.length == 0
                    s.colorize(:green) 
                elsif @winner_coords.include?([row_index, col_index]) 
                    s.colorize(:black).on_light_yellow 
                else 
                    s
                end
                "#{str} │ " 
            end.join.to_s
            body += "\n"
        end
        display = "#{columns}\n#{line}\n#{body}#{line}"
        puts display
    end
end


# Game.new.run
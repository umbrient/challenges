require 'pry-byebug'
require 'colorize'

class StepGenerator

    def initialize (board)
        @board = board
    end 

    def one_step_anywhere(coord)
        coords = []
        coords << [coord.first + 1, coord.last]
        coords << [coord.first + 1, coord.last + 1]
        coords << [coord.first + 1, coord.last - 1]
        coords << [coord.first - 1, coord.last]
        coords << [coord.first - 1, coord.last + 1]
        coords << [coord.first - 1, coord.last - 1]
        coords << [coord.first, coord.last + 1]
        coords << [coord.first, coord.last - 1]
    end

    def top_left_diag(coord) 
        coords = []
        (1..7).each do |i| 
            coords << [coord.first - i, coord.last - i]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def top_right_diag(coord)
        coords = []
        (1..7).each do |i| 
            coords << [coord.first - i, coord.last + i]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def bot_left_diag(coord)
        coords = []
        (1..7).each do |i| 
            coords << [coord.first + i, coord.last - i]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def bot_right_diag(coord) 
        coords = []
        (1..7).each do |i| 
            coords << [coord.first + i, coord.last + i]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def diagonal(coord)
        [*top_left_diag(coord), *bot_left_diag(coord), *top_right_diag(coord), *bot_right_diag(coord)]
    end


    def up(coord)
        coords = []
        (1..7).each do |i|
            coords << [coord.first - i, coord.last]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def down(coord)
        coords = []
        (1..7).each do |i|
            coords << [coord.first + i, coord.last]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def left(coord)
        coords = []
        (1..7).each do |i|
            coords << [coord.first, coord.last - i]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end

    def right(coord)
        coords = []
        (1..7).each do |i|
            coords << [coord.first, coord.last + i]
            break if coords.any? { |c| @board.get_block(c).is_a? Piece }
        end
        coords
    end


    def horizontal(coord)
        [*right(coord), *left(coord)]
    end

    def vertical(coord) 
        [*up(coord), *down(coord)]
    end

    def knight(piece)
        p_m = piece.color == "white" ? :- : :+
        p_m_reverse = piece.color == "white" ? :+ : :-
        coords = []

        coords << [piece.row - 1, piece.column + 2]
        coords << [piece.row + 1, piece.column + 2]
        coords << [piece.row + 1, piece.column - 2]
        coords << [piece.row - 1, piece.column - 2]
        
        coords << [piece.row - 2, piece.column + 1]
        coords << [piece.row + 2, piece.column + 1]
        coords << [piece.row + 2, piece.column - 1]
        coords << [piece.row - 2, piece.column - 1]
    end

end

class Piece 
    attr_accessor :name, :color, :position, :icon, :steps

    def initialize(name:,color:,position:, icon:) 

        @name = name 
        @color = color 
        @position = position
        @icon = icon

        @steps = case @name 
        when "king"
            1
        when "queen"
            7
        when "bishop"
            7
        when "rook"
            7
        when "knight"
            2
        when "pawn"
            1
        end

    end

    def row 
        self.position.first
    end

    def column 
        self.position.last
    end

    def self.get_default_location(type, color, board)
        coords = case type
        when 'king'
            [[0, 4]]
        when 'rook'
            [[0,0],[0,7]]
        when 'bishop'
            [[0,2],[0,5]]
        when 'queen'
            [[0,3]]
        when 'knight'
            [[0,1],[0,6]]
        when 'pawn'
            ([1]*8).zip (0..7).to_a
        else 
            []
        end

        coords.map! { |coord| board.mirror_position(coord) } if color == 'white'

        return coords

    end

    def moveable_coords(board, strict: false)
        
        # All coords
        board_coords = board.coords.dup
        plus_or_minus = self.color == "white" ? :- : :+
        plus_or_minus_reversed = self.color == "white" ? :+ : :-
        greater_or_less_than = self.color == "white" ? :< : :>
        greater_or_less_than_reversed = self.color == "white" ? :> : :<
        sg = StepGenerator.new(board)
        coords = Array.new
        king = board.pieces.select { |p| p.name == 'king' && p.color == self.color }.first
        

        case self.name
        
        when "king"
            coords = sg.one_step_anywhere(self.position)
        when "queen"
            coords = sg.diagonal(self.position)
            coords.push(*sg.horizontal(self.position))
            coords.push(*sg.vertical(self.position))
        when "bishop"
            coords = sg.diagonal(self.position)
        when "rook"
            coords = sg.horizontal(self.position)
            coords.push(*sg.vertical(self.position))
        when "knight"
            coords = sg.knight(self)
        when "pawn"
            steps = self.position.first == Piece.get_default_location(self.name, self.color, board)[0].first ? 2 : 1
            (1..steps).each do |i|
                coords << [self.position.first.send(plus_or_minus, i), self.position.last]
            end

            # if there's an enemy
            enemy_ahead = board.get_block([self.position.first.send(plus_or_minus, 1), self.position.last])
            if enemy_ahead.is_a?(Piece) &&  enemy_ahead.color != self.color 
                coords.reject! { |c| c.last == self.column }
            end

            enemies_around = [
                [self.position.first.send(plus_or_minus, 1), self.position.last + 1],
                [self.position.first.send(plus_or_minus, 1), self.position.last - 1]
            ]

            enemies_around.each do |enemy|
                 enemy_piece = board.get_block(enemy)
                 coords << enemy if (enemy_piece.is_a?(Piece) && enemy_piece.color != self.color)
            end
        end
        
        # Trim any coords outside of board
        # Reject any coords where mates overlap
        # Reject any coords except saviour ones if the variable is set
        coords.flatten!(1) if Piece.depth(coords) > 2
        coords = coords & board_coords
        coords.reject! { |c| board.get_block(c).is_a?(Piece) && board.get_block(c).color == self.color  }

        if strict
            # byebug
            if (board.saviour_moves[self.color.to_sym].length rescue 0) > 0
                # allowed_coords = board.saviour_moves[self.color.to_sym].map(&:last)
                allowed_coords = board.saviour_moves[self.color.to_sym].dup
                original_coords = coords
                
                # restrict movements only to ones that will save the king
                allowed_coords.reject! { |c| c.first.object_id != self.object_id }
                coords = coords & allowed_coords.map(&:last)

                # puts "Reduced allowed coords from #{original_coords} to #{coords} due to saviours."
            end

            # will any of my moves get the king checked?
            risky = []
            coords.each do |c|
                board.move(self, c)
                risky << c if board.checked(king).length > 0
                board.undo_last_move
            end
            coords = coords - risky if risky.length > 0

        end

        return coords
    end

    def self.depth(a)
        return 0 unless a.is_a? Array
        return 1 + depth(a[0])
    end

    def self.get_icon(name, color)

        icon = case name
        when 'king'
            '♔♚'
        when 'queen'
            '♕♛'
        when 'rook'
            '♖♜'
        when 'bishop'
            '♗♝'
        when 'knight'
            '♘♞'
        when 'pawn'
            '♙♟︎'
        end
        
        white,black = icon.split("")

        return color == white ? white : black
    end


end 

class Board 

    attr_accessor :display, :highlighted_coords, :pieces, :checked_coords, :checking_coords, :saviour_moves, :last_move

    def initialize(pieces)
        @pieces = pieces
        @last_killed = nil
        @last_move = {}
        @display = []
        @saviour_moves = {}
        @highlighted_coords = []
        @checked_coords = []
        @checking_coords = []
        reset
    end 

    def find(piece, color) 
        pieces.select { |p| p.name == piece && p.color == color}.first
    end

    def at_least_one_can_move(color)
        @pieces.select { |p| p.color == color && p.moveable_coords(self, strict: true).length > 0 }
    end

    def reset
        @display = [
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0]
        ]
    end

    def coords 
        the_coords = []
        @display.each_with_index {|row, row_index| row.each_with_index {|cell, cell_index| the_coords << [row_index,cell_index] }  }
        return the_coords
    end

    def move(piece, input)
        input = Board.letnum_to_coords(input)
        block = self.get_block(input)
        position_before_moving = piece.position
        piece.position = input

        # Promote 
        last_row = piece.color == "white" ? display.index(display.first) : display.index(display.last)
        if piece.position.first == last_row && piece.name == "pawn"       
            loop do 
                puts "\nChoose a piece to promote to:\n1 - Queen\n2 - Rook\n3- Bishop\n4 - Knight"
                input = gets.chomp.to_s
                if ["1","2","3","4"].include? input
                    type = case input 
                    when "1"
                        "queen"
                    when "2"
                        "rook"
                    when "3"
                        "bishop"
                    when "4"
                        "knight"
                    end 
                    piece.icon = Piece.get_icon(type, piece.color)
                    piece.name = type
                    break 
                end
            end
        end

        # Kill
        if block.is_a? Piece
            self.pieces.reject! { |p| p == block} 
            @last_killed = block
        else 
            @last_killed = nil
        end

        update_board
       
        @last_move = {
            piece: piece,
            position_before_moving: position_before_moving,
        }
        
        return block
    end

    def undo_last_move 
        unless @last_killed.nil?
            @pieces << @last_killed 
            # puts "reviving #{@last_killed.color} #{@last_killed.name} and moving them to #{@last_killed.position}"
        end 
        # puts "moving #{@last_move[:piece].color} #{@last_move[:piece].name} from #{@last_move[:piece].position} back to #{@last_move[:position_before_moving]}"
        @last_move[:piece].position = @last_move[:position_before_moving]
        update_board
    end

    def highlight(coords) 
        coords.each do |coord|
            @highlighted_coords << coord
        end
    end

    def self.coords_to_letnum(coords)
        "#{('a'..'h').to_a[coords.last]}#{coords.first + 1}"
    end

    def self.letnum_to_coords(letnum)
        return letnum if letnum.is_a?(Array) && letnum.length == 2
        letnum = letnum.split("")
        col = ('a'..'h').to_a.index(letnum.first.to_s.downcase)
        row = (letnum.last.to_i - 1)
        [row, col]
    end

    def get_block(coords)

        if ('a'..'h').include? coords.first.to_s.downcase 
            coords[0] = ('a'..'h').to_a.index(coords.first.to_s.downcase)
            row = coords.last.to_i - 1
            col = coords.first
        else 
            row = coords.first
            col = coords.last
        end

        @display[row][col] rescue false
    end

    def checked(piece)
        @pieces.select { |pi| pi.color != piece.color && pi.moveable_coords(self).include?(piece.position) }
        .map(&:position)
    end

    def any_check?
        white_king = @pieces.select { |piece| piece.name == "king" && piece.color == "white"}.first
        black_king = @pieces.select { |piece| piece.name == "king" && piece.color == "black"}.first

        [check?(white_king), check?(black_king)].include? true 
    end

    def check?(king)
        @checked_coords = []
        @checking_coords = []

        attacking_enemy = checked(king)
        if attacking_enemy.length > 0
            # puts "#{king.color} #{king.name} (#{king.position}) is being checked by #{attacking_enemy.map {|e| self.get_block(e) } }"
            attacking_enemy.each do |e|
                piece = self.get_block(e)
                # puts "#{piece.color} #{piece.name} can move to: #{piece.moveable_coords(self)}"
            end
            @checked_coords << king.position
            @checking_coords.push(*attacking_enemy)
        end
        return attacking_enemy.length > 0
    end

    def checkmate?
        return false if @checked_coords.length == 0
        still_checked = true
        moves_checked = []
        buddies_checked = []
        saviour_moves = []
        temp_board = self.dup
        temp_board.pieces = self.pieces.map(&:dup)
        buddies = nil

        # @saviour_moves = {}
        # puts "checked coords are #{@checked_coords}"        
        @checked_coords.each do |king|
            saviour_moves = []
            color = temp_board.get_block(king).color 
            buddies = temp_board.pieces.select { |pi| pi.color == color }

            buddies.each do |buddy|  
                king = buddies.select { |b| b.name == 'king' }.first
                moves = buddy.moveable_coords(temp_board)
                moves.each do |move|
                    # puts "Test piece: #{buddy}"
                    # puts "King: #{king}, can move to: #{moves}"
                    # puts "Testing: #{buddy.color}/#{buddy.icon} at #{move} (#{moves_checked.length}/#{moves.length})"
                    temp_board.move(buddy, move)
                    unless temp_board.check?(king)
                        # byebug
                        still_checked = false
                        # puts "Saveable."
                        # need to store this byref cus if I store the temp one, it messes shiz up.
                        # namely, the position doesn't seem to get updated nd sh
                        real_piece = self.pieces.select { |rp| rp.position == temp_board.last_move[:position_before_moving] }.first
                        saviour_moves << [real_piece, move]
                    else 
                        # puts "Nope. King still checked."
                    end
                    moves_checked << move
                    temp_board.undo_last_move
                end
                buddies_checked << buddy
            end

            @saviour_moves[color.to_sym] = saviour_moves
            # puts "saviour moves............."
            # puts @saviour_moves.inspect
        end

        # puts "I've checked #{moves_checked.length} moves across #{buddies_checked.length} allied piece(s)."
        # puts "Saveable moves are #{saviour_moves.inspect}"

        return still_checked

    end

    def update_board
        reset
        self.pieces.each { |piece| self.display[piece.row][piece.column] = piece } 
    end

    def draw
        reset
        columns = ('a'..'h').map { |c| "  #{c} " }.join
        
        update_board

        puts "    " + columns

        str = ''
        @display.each_with_index do |row, row_index|

            str += "  "
            row.each_with_index do |cell, cell_index|
                color = (row_index + cell_index).odd? ? 'light_black' : 'light_red'
                str += (row_index + 1).to_s + " " if cell_index == 0
                cell_content = ' '
                celltext_color = ''

                if cell.is_a? Piece 
                    cell_content = cell.icon
                    celltext_color = cell.color

                    color = "red" if @checked_coords.include? cell.position
                    color = "yellow" if @checking_coords.include? cell.position

                end

                # Highlight the block
                coord = [row_index, cell_index]
                if @highlighted_coords.include? coord 
                    color = cell.is_a?(Piece) ? 'cyan' : 'light_cyan'
                end

                str += " #{cell_content}  ".colorize(celltext_color.to_sym).send("on_#{color.to_s}")
            end
            str += "\n"
        end
        puts str
        puts "    " + columns + "\n\n\n"
        @highlighted_coords = []
    end

    def place(piece) 
    end

    def mirror_position(coords)
        # mirrors the coordinates on the x axis, keeping the y one the same. 
        # also accommodates board size
        [(@display.length - 1) - coords.first, coords.last]
    end

end

class Game 


    def initialize
        @player1 = Player.new 
        @player2 = Player.new
        @board = Board.new(Array.new)
        @killed = []
        @current_player = nil
        greet 
        ask_names_and_teams
        set_current_player
        generate_pieces
        play
    end

    def pieces 
        @board.pieces
    end

    def generate_pieces
        2.times do |i|
            color = i == 1 ? "black" : "white"
            %w(king rook bishop queen knight pawn).each do |type| 
                locations = Piece.get_default_location(type, color, @board)
                locations.each do |location|

                    # first iteration should be black positions (default in the code), second should be white positions
                    pieces << Piece.new(
                        name: type,
                        icon: Piece.get_icon(type, color),
                        color: color,
                        position: location
                    )
                end
            end
        end
    end

    def set_current_player
        @current_player = random_player
    end

    def random_player
        [@player1,@player2].select{ |p| p.team == 'white' }.first
    end

    def switch_player
        @current_player = @current_player == @player1 ? @player2 : @player1 
    end 

    def clear 
        puts "\e[H\e[2J"
        puts "You can always type 'save' to save the game.\n\n" unless @current_player.nil?
    end

    def greet
        puts "Welcome to 2-player Chess!"
    end

    def can_load_game?
        (Dir.exists?("saved_games") && ((saves.length rescue 0) > 0))
    end

    def save_profile_name
        Dir.mkdir("saved_games") unless Dir.exists?("saved_games")
        file_count = saves.length rescue 0
        "./saved_games/save_data_#{file_count + 1}_#{Time.now.strftime("%d.%m.%y")}.txt"
    end

    def saves
        Dir.glob("./saved_games/*.txt")
    end

    def show_saves
        puts "\n\nSaved Game Profiles:\n\n"
        saves.each_with_index { |s, index| puts "#{index + 1}) #{File.basename(s)}" }
    end

    def get_input(msg, validation, duplicate = nil, do_clear: true)
        input = ""

        loop do 
            passed = false 
            puts msg
            input = gets.chomp.downcase

            if input == "save"
                show_saves
                puts "None found, saving new...\n\n" unless can_load_game?
                sered_game = Marshal.dump(self)
                fname = save_profile_name
                File.open(fname, "w") { |f| f.write(sered_game) } 
                puts File.exists?(fname) ? "Saved successfully." : "Error: not saved!"
            else 
                if validation.is_a? Array 
                    passed = validation.map(&:to_s).include? input
                elsif validation.is_a? Regexp
                    passed = input.match? validation
                end
            end

            break if passed && duplicate != input
        end
        clear if do_clear
        return input
    end

    def teams
        ["white", "black"]
    end

    def ask_names_and_teams
        clear

        skip_configuration = false
        if can_load_game?
            load_game = get_input("Would you like to load a saved game?", ['y', 'n'])
            if load_game == 'y'
                show_saves
                input = get_input("\nPlease pick a profile to load", (1..saves.length).to_a)
                unless input.nil?
                    data = File.read("#{saves[input.to_i - 1]}")
                    game = Marshal.load(data)
                    game.play
                end
            end
        end 

        unless skip_configuration
            @player1.name = get_input("Player 1, what's your name?", /^[A-Za-z0-9]{1,7}$/)
            @player1.team = get_input("Hi #{@player1.name}! Next, please pick a team (white/black)?", teams)

            @player2.name = get_input("Player 2, what's your name?", /^[A-Za-z0-9]{1,7}$/, @player1.name)
            @player2.team = (teams - [@player1.team]).first
        end
    end

    def play
        loop do 
            piece = nil
            loop do
                @board.draw
                placed = false 
                input = get_input("#{@current_player.name} (#{@current_player.team} team), select a piece using the board (e.g. b1, c5 etc.)", /^[A-Ha-h]{1}[1-8]{1}$/, do_clear: false)
                validated = validate_selection(input.downcase.split(""))

                if validated.is_a? Piece    
                    piece = validated

                    # strict means it will exclude any moves that will lose you the game.
                    # byebug
                    coords = piece.moveable_coords(@board, strict: true)
                    
                    @board.highlight(coords)
                    loop do 
                        clear 
                        @board.draw
                        input = get_input("#{@current_player.name} (#{@current_player.team} team), pick a valid position, or enter 'c' to cancel selection.", ['c', *coords.map { |coord| Board.coords_to_letnum(coord) } ] , do_clear: true)
                        if input == 'c'
                            # player wants to cancel
                            piece = nil
                            clear
                            break
                        else 
                            # player has picked a valid piece and position
                            moved = @board.move(piece, input)
                            @board.saviour_moves = {}
                            # byebug
                            @killed << moved if moved.is_a? Piece 
                            if @board.any_check?
                                mark_check
                                game_over if @board.checkmate?
                            else 
                                # puts "clearing coordinates since nothing is checked anymore"
                                @checked_coords = []
                                @checking_coords = []
                            end
                            placed = true
                            break
                        end 
                    end
                else 
                    # player's selection is invalid
                    clear
                    puts "\n#{validated.white.on_red}\n\n"
                end
                break if placed
            end
            
            switch_player
        end
    end

    def game_over
        @board.draw
        puts "Checkmate son, ggs. #{@current_player.name.capitalize} wins."
        exit
    end

    def mark_check
        puts "\n#{"Check!".red.on_white}\n\n"
    end

    def validate_selection(coords)
        piece = @board.get_block(coords)

        return "Invalid input." unless coords.length == 2 
        return "That's an empty space." unless piece.is_a? Piece 
        return "That piece does not belong to you." unless piece.color == @current_player.team
        return "That piece cannot move anywhere at the moment." if (piece.moveable_coords(@board, strict: true ).length == 0 && @board.at_least_one_can_move(piece.color))

        return piece
    end

end

class Player 

    attr_accessor :name, :team

    def initialize(name: nil, team: nil)
        @name = name 
        @team = team
    end

end



game = Game.new
require '../tictactoe.rb'

describe Game do


    describe "initialize" do

        let(:game) { described_class.new }
        let(:computer_mode) { 'y' }
        let(:player_moves) { [ '1', '2', '3' ] } 
        let(:opponent_moves) { [ '4', '5', '6' ] } 
        let(:player_symbol) { 'X' }


        subject(:play) do 
            puts "running again"
            allow(game).to receive(:gets).and_return(computer_mode, *player_moves)
            allow(game).to receive(:generate_computer_move).and_return(*opponent_moves)
            allow(game).to receive(:random_player).and_return(player_symbol)
            game.begin
        end


        context 'when the game starts' do 

            it 'greets the player' do 
                expect(game).to receive(:greet_player).once                
                play
            end

            it 'asks the player to choose a mode' do
                expect(game).to receive(:ask_mode).and_call_original        
                play
            end
        end 

        context 'when playing against opponent' do 
            context 'when the player wins horizontally' do
                context 'across the top' do 
                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end

                context 'across the middle' do 

                    let(:player_moves) { ['4', '5', '6'] }
                    let(:opponent_moves) { ['1', '2', '3'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end


                context 'across the bottom' do 

                    let(:player_moves) { ['7', '8', '9'] }
                    let(:opponent_moves) { ['4', '5', '6'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end
            end

            context 'when the player wins vertically' do
                context 'top-down left' do 
                    let(:player_moves) { ['1', '4', '7'] }
                    let(:opponent_moves) { ['5', '6', '7'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end
                context 'top-down middle' do 

                    let(:player_moves) { ['2', '5', '8'] }
                    let(:opponent_moves) { ['1', '2', '3'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end
                context 'top-down right' do 

                    let(:player_moves) { ['9', '6', '3'] }
                    let(:opponent_moves) { ['1', '2', '3'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end
            end

            context 'when the player wins diagonally' do
         
                context 'top-left to bottom-right' do 

                    let(:player_moves) { ['1', '5', '9'] }
                    let(:opponent_moves) { ['4', '2', '3'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end
                context 'top-right to bottom-left' do 

                    let(:player_moves) { ['3', '5', '7'] }
                    let(:opponent_moves) { ['1', '2', '3'] }

                    it 'announces the player as the winner' do 
                        expect(game).to receive(:announce_winner).with(player_symbol)
                        play
                    end
                end
            end
        end

        context 'when the opponent wins' do

            let(:player_moves) { ['1', '2', '8'] }
            let(:opponent_moves) { ['4', '5', '6'] }

            it 'announces it' do 
                expect(game).not_to receive(:announce_winner).with(player_symbol)
                play 
            end
        end
    end




end
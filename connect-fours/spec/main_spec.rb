require '../lib/main.rb'
require 'pry-byebug'


describe Game do

    let(:player_1) { 'Player1' }
    let(:player_2) { 'Player2' }
    let(:game) { described_class.new }
    let(:player_1_moves) { '0000'.split('') }
    let(:player_2_moves) { '1111'.split('') }
    let(:moves) { player_1_moves.zip(player_2_moves).flatten.compact }
    let(:names) { [player_1, player_2] }
    let(:args) { ['y', *names, *moves] }


    subject(:play) do 
        allow(game).to receive(:gets).and_return(*args)
        allow(game).to receive(:get_input).and_call_original
        game.run
    end
    
    context 'when the game starts' do 
        it 'greets the players' do
            expect(game).to receive(:greet).exactly(:once)
            play
        end

        it 'displays the rules' do 
            expect(game).to receive(:rules).exactly(:once)
            play
        end

        it 'asks the user to pick names' do 
            expect(game).to receive(:pick_names).exactly(:once)
            play
        end

        it 'starts the game' do
            expect(game).to receive(:play_the_game).exactly(:once)
            play
        end

    end

    describe '#pick_names' do 
        context 'when picking names' do
            let(:names) { ['bob', 'bob', 'bob', 'ok'] }

            it 'rejects duplicates' do
                expect(game).to receive(:get_input).with(/unique/, anything).exactly(4).times
                play
            end
        end
    end

    context 'when a player wins' do
        context 'vertically' do 
            it 'announces the winner' do 
                expect(game).to receive(:winner).exactly(:once)
                play
            end
        end

        context 'horizontally' do 
            let(:player_1_moves) { '0123'.split('') }
            let(:player_2_moves) { '4444'.split('') }

            it 'announces the winner' do 
                expect(game).to receive(:winner).exactly(:once)
                play
            end
        end

        context 'diagonally going right' do 
            let(:player_1_moves) { '013233'.split('') }
            let(:player_2_moves) { '122343'.split('') }

            it 'announces the winner' do 
                expect(game).to receive(:winner).exactly(:once).and_call_original
                play
            end
        end

        context 'diagonally going left' do 
            let(:player_1_moves) { '653433'.split('') }
            let(:player_2_moves) { '544323'.split('') }

            it 'announces the winner' do 
                expect(game).to receive(:winner).exactly(:once).and_call_original
                play
            end
        end
    end 
end
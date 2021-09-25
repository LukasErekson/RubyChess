# frozen_string_literal: true

require 'rspec'
require_relative '../lib/board'

# Require all the chess pieces
Dir.children('./lib/chess_pieces').each { |piece_file| require_relative "../lib/chess_pieces/#{piece_file}" }

RSpec.describe 'Board#move' do
  let(:board) { Board.new }
  let(:game_board) { board.instance_variable_get(:@game_board) }
  describe 'first turn' do
    context 'when a white pawn moves' do
      it 'lets pawn move forward one' do
        8.times do |col|
          expect(proc {
                   board.move([1, col], [2, col]); board.instance_variable_set(:@current_player_color, 'white')
                 }).to change {
                         game_board[1][col]
                       }.to('  ')
        end
      end

      it 'lets pawn move forward two' do
        8.times do |col|
          expect(proc {
                   board.move([1, col], [3, col]); board.instance_variable_set(:@current_player_color, 'white')
                 }).to change {
                         game_board[1][col]
                       }.to('  ')
        end
      end

      it 'flags pawn as having moved afterward' do
        8.times do |col|
          board.move([1, col], [3, col])
          board.instance_variable_set(:@current_player_color, 'white')
          expect(game_board[3][col].has_moved).to be true
        end
      end
    end

    context 'when a white knight moves' do
      it 'lets knight move to valid space' do
        expect(proc {
                 board.move([0, 1], [2, 0]); board.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       game_board[0][1]
                     }.to('  ')
        expect(proc {
                 board.move([0, 6], [2, 5]); board.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       game_board[0][6]
                     }.to('  ')
        expect(proc {
                 board.move([2, 0], [0, 1]); board.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       game_board[2][0]
                     }.to('  ')
        expect(proc {
                 board.move([2, 5], [0, 6]); board.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       game_board[2][5]
                     }.to('  ')
        expect(proc {
                 board.move([0, 1], [2, 2]); board.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       game_board[0][1]
                     }.to('  ')
        expect(proc {
                 board.move([0, 6], [2, 7]); board.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       game_board[0][6]
                     }.to('  ')
      end
    end

    context 'when black pawn moves' do
      it 'raises InvalidMoveError' do
        expect(proc { board.move([6, 0], [5, 0]) }).to raise_error(InvalidMoveError)
      end
    end
  end
end

# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_game'
require_relative '../lib/invalid_move_error'

# Require all the chess pieces
Dir.children('./lib/chess_pieces').each { |piece_file| require_relative "../lib/chess_pieces/#{piece_file}" }

##
# Creates a board placing pieces using a location => piece hash.
def setup_board(loc_to_piece_hash = {})
  board = Array.new(8) { Array.new(8, ChessGame::BLANK_SQUARE) }

  loc_to_piece_hash.each do |loc, piece|
    row, col = loc
    board[row][col] = piece
  end

  board
end

RSpec.describe 'ChessGame#make_move' do
  let(:game) { ChessGame.new }
  let(:board) { game.instance_variable_get(:@board) }

  describe 'standard setup' do
    context 'when moving pawns' do
      it 'lets them move 1 space on their first turn' do
        8.times do |col|
          expect(proc { game.make_move([1, col], [2, col]) }).not_to raise_error
          expect(proc { game.make_move([6, col], [5, col]) }).not_to raise_error
        end
      end

      it 'lets them move 2 spaces on their first turn' do
        8.times do |col|
          expect(proc { game.make_move([1, col], [3, col]) }).not_to raise_error
          expect(proc { game.make_move([6, col], [4, col]) }).not_to raise_error
        end
      end
    end

    context 'when moving knights' do
      it 'lets the left knights move' do
        expect(proc { game.make_move([0, 1], [2, 2]) }).not_to raise_error
        expect(proc { game.make_move([7, 1], [5, 2]) }).not_to raise_error
      end

      it 'lets the right knights move ' do
        expect(proc { game.make_move([0, 6], [2, 5]) }).not_to raise_error
        expect(proc { game.make_move([7, 6], [5, 5]) }).not_to raise_error
      end
    end
  end

  describe 'inidividual pieces' do
    context 'queens' do
      it 'allows queens to move vertically' do
        queens = { [0, 0] => Queen.new('white', [0, 0]), [7, 7] => Queen.new('black', [7, 7]) }
        game.instance_variable_set(:@board, setup_board(queens))
        expect(proc { game.make_move([0, 0], [7, 0]) }).not_to raise_error
        expect(proc { game.make_move([7, 7], [0, 7]) }).not_to raise_error
      end

      it 'allows queens to move horizontally' do
        queens = { [0, 0] => Queen.new('white', [0, 0]), [7, 7] => Queen.new('black', [7, 7]) }
        game.instance_variable_set(:@board, setup_board(queens))
        expect(proc { game.make_move([0, 0], [0, 7]) }).not_to raise_error
        expect(proc { game.make_move([7, 7], [7, 0]) }).not_to raise_error
      end
    end
  end
end

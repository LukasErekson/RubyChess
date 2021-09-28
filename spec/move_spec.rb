# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_game'

# Require all the chess pieces
Dir.children('./lib/chess_pieces').each { |piece_file| require_relative "../lib/chess_pieces/#{piece_file}" }

##
# Creates a board placing pieces using a location => piece hash.
def setup_board(loc_to_piece_hash={})
  board = Array.new(8) { Array.new(8, ChessGame::BLANK_SQUARE) }

  loc_to_piece_hash.each do |loc, piece|
    row, col = loc
    board[row][col] = piece
  end

  board
end

RSpec.describe 'ChessGame#move' do
  let(:game) { ChessGame.new }
  let(:board) { game.instance_variable_get(:@board) }
  


end

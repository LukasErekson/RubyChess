# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_game'
require_relative '../lib/invalid_move_error'

# Require all the chess pieces
Dir.children('./lib/chess_pieces').each { |piece_file| require_relative "../lib/chess_pieces/#{piece_file}" }

RSpec.describe ChessGame do
  let(:game) { ChessGame.new }
  let(:board) { game.instance_variable_get(:@board) }
  describe '#board_pieces' do
    context 'with the standard setup' do
      it 'returns an array of just pieces' do
        board_pieces_output = game.board_pieces_by_color
        expect(board_pieces_output.flatten.size).to be(32)
        expect(board_pieces_output.flatten.all? { |piece| piece.is_a? ChessPiece }).to be(true)
      end
      it 'splits pieces between black and white' do
        board_pieces_output = game.board_pieces_by_color
        expect(board_pieces_output.size).to be(2)
        expect(board_pieces_output[0].all? { |piece| piece.color == 'white' }).to be(true)
        expect(board_pieces_output[1].all? { |piece| piece.color == 'black' }).to be(true)
      end
    end

    context 'after a move' do
      it 'returns an array of just pieces' do
        game.make_move([1, 0], [2, 0])
        board_pieces_output = game.board_pieces_by_color
        expect(board_pieces_output.flatten.size).to be(32)
        expect(board_pieces_output.flatten.all? { |piece| piece.is_a? ChessPiece }).to be(true)
      end
    end
  end
end

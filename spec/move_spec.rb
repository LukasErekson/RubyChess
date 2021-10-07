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

RSpec.describe 'ChessGame#make_move and its sub-methods' do
  let(:game) { ChessGame.new }
  let(:board) { game.instance_variable_get(:@board) }

  describe 'ChessGame#validate_move' do
    context 'when there is no piece at from' do
      it 'raises an InvalidMoveError' do
        expect(proc { game.validate_move([3, 3], [2, 3]) }).to raise_error(InvalidMoveError)
      end
    end
    context 'when one tries to move an opponent\'s piece' do
      it 'raises an InvalidMoveError on white\'s turn' do
        expect(proc { game.validate_move([7, 7], [6, 7]) }).to raise_error(InvalidMoveError)
      end
      it 'raises an InvalidMoveError on black\'s turn' do
        game.instance_variable_set(:@current_player_color, 'black')
        expect(proc { game.validate_move([1, 1], [2, 1]) }).to raise_error(InvalidMoveError)
      end
    end
    context 'when one tries to make an illegal move' do
      it 'raises an InvalidMoveError for move outside of move tree' do
        expect(proc { game.validate_move([1, 1], [5, 1]) }).to raise_error(InvalidMoveError)
      end
      it 'raises an InvalidMoveError for a piece that is blocked by another' do
        expect(proc { game.validate_move([0, 0], [1, 0]) }).to raise_error(InvalidMoveError)
      end
    end
  end

  describe 'ChessGame#legal_moves' do
    context 'with the standard setup' do
      it 'each pawn has 2 legal moves' do
        pieces_array = board.flatten.filter { |space| space.is_a? ChessPiece }
        pieces_array.filter { |piece| piece.is_a? Pawn }.each do |pawn|
          expect(game.legal_moves(pawn).length).to eq(2)
        end
      end
      it 'each knight has 2 legal moves' do
        pieces_array = board.flatten.filter { |space| space.is_a? ChessPiece }
        pieces_array.filter { |piece| piece.is_a? Knight }.each do |knight|
          expect(game.legal_moves(knight).length).to eq(2)
        end
      end
      it 'every other piece has no legal moves' do
        pieces_array = board.flatten.filter { |space| space.is_a? ChessPiece }
        pieces_array.reject { |piece| (piece.is_a? Knight) || (piece.is_a? Pawn) }.each do |piece|
          expect(game.legal_moves(piece).length).to eq(0)
        end
      end
    end

    # TODO : Test other contexts using setup_board
    context 'individual pieces' do
      it 'lets a pawn capture a piece to its diagonal' do
        pawn = Pawn.new('white', [1, 1])
        current_board = { [1, 1] => pawn, [2, 0] => Bishop.new('black', [2, 0]) }
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.legal_moves(pawn)).to be_include([2, 0])
      end

      it 'lets a pawn perform En Passant' do
        # Set up the pawns on the board
        pawn = Pawn.new('white', [3, 3])
        capture_pawn = Pawn.new('black', [6, 2])
        current_board = [pawn, capture_pawn].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))

        # Makemove to make En Passant legal
        game.make_move([3, 3], [4, 3])
        game.make_move([6, 2], [4, 2])
        expect(game.legal_moves(board[4][3])).to be_include([5, 2])
      end
    end
  end

  describe '#make_move' do
    # TODO : Test things like the board updating, changing the king's position
    # variables correctly, etc.

    it 'lets a pawn perform En Passant' do
      # Set up the pawns on the board
      pawn = Pawn.new('white', [3, 3])
      capture_pawn = Pawn.new('black', [6, 2])
      current_board = [pawn, capture_pawn].each_with_object({}) do |piece, hash|
        hash[piece.position] = piece
      end
      game.instance_variable_set(:@board, setup_board(current_board))

      # Makemove to make En Passant legal
      game.make_move([3, 3], [4, 3])
      game.make_move([6, 2], [4, 2])
      expect(proc { game.make_move([4, 3], [5, 2]) }).to change { board[4][2] }.to(ChessGame::BLANK_SQUARE)
    end
  end
end

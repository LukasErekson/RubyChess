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

    context 'when a piece is in the way of another' do
      it 'lets the rook capture an enemy piece' do
        rook = Rook.new('white', [0, 0])
        pawn = Pawn.new('black', [5, 0])
        current_board = [rook, pawn].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.legal_moves(rook)).not_to be_include([6, 0])
        expect(game.legal_moves(rook)).to be_include([5, 0])
      end
      it 'does not let the rook capture its own piece' do
        rook = Rook.new('white', [0, 0])
        pawn = Pawn.new('white', [5, 0])
        current_board = [rook, pawn].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.legal_moves(rook)).not_to be_include([6, 0])
        expect(game.legal_moves(rook)).not_to be_include([5, 0])
      end
    end

    # TODO : Test other contexts using setup_board
    context 'individual pieces' do
      it 'allows a king to capture a pawn-turned queen' do
        king = King.new('black', [7, 3])
        rook = Rook.new('black', [7, 4])
        pawn = Pawn.new('white', [6, 5])
        current_board = [pawn, rook, king].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.legal_moves(pawn)).to be_include([7, 4])
        $stdin = StringIO.new("1\n")
        $stdout = StringIO.new
        game.make_move([6, 5], [7, 4])
        $stdin = STDIN
        $stdout = STDOUT
        expect(game.legal_moves(king)).to be_include([7, 4])
        game.make_move([7, 3], [7, 4])
      end
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
    it 'captures a pawn using En Passant' do
      # Set up the pawns on the board
      pawn = Pawn.new('white', [3, 3])
      capture_pawn = Pawn.new('black', [6, 2])
      current_board = [pawn, capture_pawn].each_with_object({}) do |piece, hash|
        hash[piece.position] = piece
      end
      game.instance_variable_set(:@board, setup_board(current_board))

      # Make move to make En Passant legal
      game.make_move([3, 3], [4, 3])
      game.make_move([6, 2], [4, 2])
      expect(proc { game.make_move([4, 3], [5, 2]) }).to change { board[4][2] }.to(ChessGame::BLANK_SQUARE)
    end

    it 'updates the board locations' do
      expect(proc { game.make_move([1, 1], [3, 1]) }).to change { board[1][1] }.to(ChessGame::BLANK_SQUARE).and change {
                                                                                                                  board[3][1].is_a?(Pawn)
                                                                                                                }.to(true)
    end

    it 'updates the king locations' do
      white_king = King.new('white', [3, 3])
      black_king = King.new('black', [6, 2])
      current_board = [white_king, black_king].each_with_object({}) do |piece, hash|
        hash[piece.position] = piece
      end
      game.instance_variable_set(:@board, setup_board(current_board))
      game.instance_variable_set(:@king_locs, { white: [3, 3], black: [6, 2] })
      king_locs = game.instance_variable_get(:@king_locs)

      expect(proc { game.make_move([3, 3], [3, 4]) }).to change { king_locs[:white] }.to([3, 4])
      expect(proc { game.make_move([6, 2], [7, 2]) }).to change { king_locs[:black] }.to([7, 2])
    end
  end

  describe '#check_check' do
    context 'when a king is not in check' do
      it 'returns nil' do
        expect(game.check_check).to eq(nil)
      end
    end

    context 'when the black king is in check' do
      it 'returns the pawn that puts it in check' do
        pawn = Pawn.new('white', [3, 3])
        king = King.new('black', [4, 4])
        current_board = [pawn, king].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { black: [4, 4] })
        expect(game.check_check).to eq(pawn)
      end

      it 'returns the bishop that puts it in check' do
        bishop = Bishop.new('white', [0, 0])
        king = King.new('black', [7, 7])
        current_board = [bishop, king].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { black: [7, 7] })
        expect(game.check_check).to eq(bishop)
      end
    end
  end

  describe '#available_moves' do
    context 'when the king can get out of check by moving out of the way' do
      it 'returns moves the white king can make' do
        king_white = King.new('white', [0, 0])
        bishop_black = Bishop.new('black', [3, 3])
        current_board = [king_white, bishop_black].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { white: [0, 0] })
        expect(game.available_moves).to eq({ [0, 0] => [[0, 1], [1, 0]] })
      end
      it 'returns moves the black king can make' do
        king_black = King.new('black', [7, 7])
        rook_white = Rook.new('white', [6, 0])
        current_board = [king_black, rook_white].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { black: [7, 7] })
        game.make_move([6, 0], [7, 0])
        expect(game.available_moves).to eq({ [7, 7] => [[6, 6], [6, 7]] })
      end
    end

    context 'when the player can move a piece (not the king) to get out of check' do
      it 'returns move that blocks it' do
        king_white = King.new('white', [0, 0])
        # Convoluted setup so that only one block is possible.
        bishop_white1 = Bishop.new('white', [1, 0])
        bishop_white2 = Bishop.new('white', [0, 1])
        bishop_white3 = Bishop.new('white', [1, 3])
        bishop_black = Bishop.new('black', [3, 3])
        current_board = [king_white, bishop_black, bishop_white1, bishop_white2,
                         bishop_white3].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { white: [0, 0] })
        expect(game.available_moves).to eq({ [1, 3] => [[2, 2]] })
      end
    end

    context 'when it is checkmate' do
      it 'returns nil' do
        king_white = King.new('white', [0, 0])
        bishop_white1 = Bishop.new('white', [1, 0])
        bishop_white2 = Bishop.new('white', [0, 1])
        bishop_black = Bishop.new('black', [3, 3])
        current_board = [king_white, bishop_black, bishop_white1, bishop_white2].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { white: [0, 0] })
        expect(game.available_moves).to eq(nil)
      end
    end
  end

  describe '#can_castle?' do
    # Using just the standard setup
    context 'when multiple pieces are in the way on the left' do
      it 'returns false for white' do
        expect(game.can_castle?([0, 4], [0, 2])).to be(false)
      end

      it 'returns false for black' do
        expect(game.can_castle?([7, 4], [7, 2])).to be(false)
      end
    end

    # Using just the standard setup
    context 'when multiple pieces ar in the way on the right' do
      it 'returns false for white' do
        expect(game.can_castle?([0, 4], [0, 6])).to be(false)
      end

      it 'returns false for black' do
        expect(game.can_castle?([7, 4], [7, 6])).to be(false)
      end
    end

    context 'when one piece is in the way' do
      it 'returns false for white' do
        king = King.new('white', [0, 4])
        bishop = Bishop.new('white', [0, 2])
        rook = Rook.new('white', [0, 0])
        current_board = [king, bishop, rook].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.can_castle?([0, 4], [0, 2])).to be(false)
      end

      it 'returns false for black' do
        king = King.new('black', [7, 4])
        bishop = Bishop.new('black', [7, 5])
        rook = Rook.new('black', [7, 7])
        current_board = [king, bishop, rook].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.can_castle?([7, 4], [7, 6])).to be(false)
      end
    end

    context 'when the king can castle' do
      it 'returns true for white' do
        king = King.new('white', [0, 4])
        rook = Rook.new('white', [0, 7])
        current_board = [king, rook].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.can_castle?([0, 4], [0, 6])).to be(true)
      end

      it 'returns true for black' do
        king = King.new('black', [7, 4])
        rook = Rook.new('black', [7, 0])
        current_board = [king, rook].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        expect(game.can_castle?([7, 4], [7, 2])).to be(true)
      end
    end

    context 'when the horizontal difference is not 2' do
      it 'returns false' do
        expect(game.can_castle?([7, 4], [7, 7])).to be(false)
      end
    end
  end

  describe 'castling the king' do
    context 'when castling the king to the left' do
      before do
        king = King.new('black', [7, 4])
        rook = Rook.new('black', [7, 0])
        current_board = [king, rook].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@current_player_color, 'black')
      end

      it 'changes @castle_king to be when validating' do
        expect(proc { game.validate_move([7, 4], [7, 2]) }).to change {
                                                                 game.instance_variable_get(:@castle_king)
                                                               }.from(false).to(true)
      end

      it 'flags @castle_king as false' do
        game.instance_variable_set(:@castle_king, true)
        expect(proc { game.make_move([7, 4], [7, 2]) }).to change {
                                                             game.instance_variable_get(:@castle_king)
                                                           }.from(true).to(false)
      end
    end

    context 'when castling the king to the right' do
      before do
        king = King.new('black', [7, 4])
        rook = Rook.new('black', [7, 7])
        current_board = [king, rook].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@current_player_color, 'black')
      end

      it 'changes @castle_king to be when validating' do
        expect(proc { game.validate_move([7, 4], [7, 6]) }).to change {
                                                                 game.instance_variable_get(:@castle_king)
                                                               }.from(false).to(true)
      end

      it 'flags @castle_king as false' do
        game.instance_variable_set(:@castle_king, true)
        expect(proc { game.make_move([7, 4], [7, 6]) }).to change {
                                                             game.instance_variable_get(:@castle_king)
                                                           }.from(true).to(false)
      end
    end
  end

  describe '#random_move' do
    context 'when called' do
      it 'gives a valid move' do
        expect(proc { game.make_move(*game.random_move) }).not_to raise_error
      end
    end
  end
end

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

  describe '#parse_move' do
    context 'when given input in the form of "{from_space}{to_space}' do
      it 'returns proper coordinates for "a2a4"' do
        expect(game.parse_move('a2a4')).to eq([[1, 0], [3, 0]])
      end

      it 'returns proper coordinates for "h8e2"' do
        expect(game.parse_move('h8e2')).to eq([[7, 7], [1, 4]])
      end
    end

    context 'when given input in the form of "{from_space} to {to_space}' do
      it 'returns proper coordinates for "a2a4"' do
        expect(game.parse_move('a2 to a4')).to eq([[1, 0], [3, 0]])
      end

      it 'returns proper coordinates for "h8e2"' do
        expect(game.parse_move('h8 to e2')).to eq([[7, 7], [1, 4]])
      end
    end
  end

  describe '#player_input_type' do
    context 'when trying to end the game' do
      %w[save quit exit end].each do |save_word|
        it "returns \"save\" when given \"#{save_word}\"" do
          expect(game.player_input_type(save_word)).to eq('save')
        end
      end
    end

    context 'when trying to access the tutorial' do
      %w[help tutorial ?].each do |help_word|
        it "returns \"help\" when given \"#{help_word}\"" do
          expect(game.player_input_type(help_word)).to eq('help')
        end
      end
    end

    context 'when given any other string' do
      %w[this is an example a2a4 h8g3].each do |str_input|
        it "returns \"move\" when given \"#{str_input}\"" do
          expect(game.player_input_type(str_input)).to eq('move')
        end
      end
    end
  end

  describe '#check_game_over' do
    context 'when white is in stalemate' do
      it 'returns "Stalemate"' do
        white_king = King.new('white', [0, 0])
        pawn = Pawn.new('black', [2, 1])
        black_king = King.new('black', [1, 2])
        current_board = [pawn, black_king, white_king].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { black: [1, 2], white: [0, 0] })
        expect(game.check_game_over).to eq('Stalemate')
      end

      it 'returns "Stalemate"' do
        white_king = King.new('white', [1, 0])
        pawn = Pawn.new('white', [1, 1])
        rook_1 = Rook.new('black', [0, 7])
        rook_2 = Rook.new('black', [2, 7])
        rook_3 = Rook.new('black', [2, 1])
        current_board = [pawn, white_king, rook_1, rook_2, rook_3].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { white: [1, 0] })
        expect(game.check_game_over).to eq('Stalemate')
      end
    end

    context 'when black is in stalemate' do
      it 'returns "Stalemate"' do
        black_king = King.new('black', [7, 7])
        pawn = Pawn.new('white', [5, 6])
        white_king = King.new('white', [6, 5])
        current_board = [pawn, black_king, white_king].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@current_player_color, 'black')
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { white: [6, 5], black: [7, 7] })
        expect(game.check_game_over).to eq('Stalemate')
      end

      it 'returns "Stalemate"' do
        black_king = King.new('black', [6, 7])
        pawn = Pawn.new('black', [6, 6])
        rook_1 = Rook.new('white', [7, 0])
        rook_2 = Rook.new('white', [5, 0])
        rook_3 = Rook.new('white', [5, 6])
        current_board = [pawn, black_king, rook_1, rook_2, rook_3].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@current_player_color, 'black')
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { black: [6, 7] })
        expect(game.check_game_over).to eq('Stalemate')
      end
    end

    context 'in checkmate situations' do
      it 'returns "Checkmate"' do
        black_king = King.new('black', [6, 7])
        rook_1 = Rook.new('white', [7, 0])
        rook_2 = Rook.new('white', [5, 0])
        rook_3 = Rook.new('white', [6, 0])
        current_board = [black_king, rook_1, rook_2, rook_3].each_with_object({}) do |piece, hash|
          hash[piece.position] = piece
        end
        game.instance_variable_set(:@current_player_color, 'black')
        game.instance_variable_set(:@check_in_play, true)
        game.instance_variable_set(:@board, setup_board(current_board))
        game.instance_variable_set(:@king_locs, { black: [6, 7] })
        expect(game.check_game_over).to eq('Checkmate')
      end
    end

    context 'in neither checkmate nor stalemate situations' do
      it 'returns "continue"' do
        expect(game.check_game_over).to eq('continue')
      end
    end
  end
end

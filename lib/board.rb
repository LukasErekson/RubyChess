# frozen_string_literal: true

require 'colorize'
require 'stringio'
require_relative 'chess_pieces/pawn'
require_relative 'chess_pieces/rook'
require_relative 'chess_pieces/knight'
require_relative 'chess_pieces/bishop'
require_relative 'chess_pieces/queen'
require_relative 'chess_pieces/king'

##
# A chess board, complete with setup of chess pieces,
# validation of moves, and computing check/checkmate.
class Board
  WHITE_SQUARE = { background: :light_red }.freeze
  BLACK_SQAURE = { background: :black }.freeze

  ##
  # Creates instance variables and sets up the board for
  # the start of the game.
  def initialize
    @game_board = setup_board
  end

  ##
  # Returns a string of a board with pieces and appropriately
  # shaded spaces.
  def to_s
    string_stream = StringIO.new
    8.downto(1) do |row|
      string_stream << " #{row} "
      @game_board[row - 1].each_with_index do |col, col_num|
        bg_color = (row - 1) % 2 == col_num % 2 ? BLACK_SQAURE : WHITE_SQUARE
        string_stream << col.to_s.colorize(bg_color)
      end
      string_stream << "\n"
    end

    string_stream << '    a b c d e f g h '

    string_stream.string
  end

  protected

  ##
  # Returns an array that sets the board up for the
  # start of the game.
  def setup_board
    # Build the empty board
    rows = place_pieces('white')
    4.times do
      blank_rows = []
      8.times { blank_rows << '  ' }
      rows << blank_rows
    end
    rows += place_pieces('black')

    rows
  end

  ##
  # Returns the 2 arrays of the chess pieces in the proper places based od
  # their color.
  def place_pieces(color)
    is_white = color == 'white'
    pawn_row = is_white ? 1 : 6
    pawns = []
    8.times { |col| pawns << Pawn.new(color, [pawn_row, col]) }

    back_row = is_white ? 0 : 7
    back_row_pieces = [Rook.new(color, [back_row, 0]),
                       Knight.new(color, [back_row, 1]),
                       Bishop.new(color, [back_row, 2]),
                       Queen.new(color, [back_row, 3]),
                       King.new(color, [back_row, 4]),
                       Bishop.new(color, [back_row, 5]),
                       Knight.new(color, [back_row, 6]),
                       Rook.new(color, [back_row, 7])]
    if is_white
      [back_row_pieces, pawns]
    else
      [pawns, back_row_pieces]
    end
  end
end

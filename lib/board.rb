# frozen_string_literal: true

require 'colorize'
require 'stringio'
require_relative 'chess_pieces/pawn'

##
# A chess board, complete with setup of chess pieces,
# validation of moves, and computing check/checkmate.
class Board
  WHITE_SQUARE = '██'.white
  BLACK_SQAURE = '  '

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
      @game_board[row - 1].each do |col|
        string_stream << col
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
    rows = Array.new(8) { [] }
    8.times do |row|
      case row
      when 1 # black pawns
        8.times { |col| rows[row] << Pawn.new('white', [row, col]) }
      when 6 # white pawns
        8.times { |col| rows[row] << Pawn.new('black', [row, col]) }
      else
        8.times do |col|
          empty_square = row % 2 == col % 2 ? WHITE_SQUARE : BLACK_SQAURE
          rows[row] << empty_square
        end
      end
    end

    rows
  end
end

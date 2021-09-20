# frozen_string_literal: true

require 'colorize'
require 'stringio'
require_relative 'chess_pieces/pawn'
require_relative 'chess_pieces/rook'
require_relative 'chess_pieces/knight'
require_relative 'chess_pieces/bishop'
require_relative 'chess_pieces/queen'
require_relative 'chess_pieces/king'
require_relative 'invalid_move_error'

##
# A chess board, complete with setup of chess pieces,
# validation of moves, and computing check/checkmate.
class Board
  WHITE_SQUARE = { background: :light_red }.freeze
  BLACK_SQAURE = { background: :black }.freeze
  BLANK_SQUARE = '  '

  ##
  # Creates instance variables and sets up the board for
  # the start of the game.
  def initialize
    @game_board = setup_board
    @current_player_color = 'white'
  end

  ##
  # Moves a piece at a given location to another location if
  # the move is valid. Raises an InvalidMoveError otherwise.
  def move(from, to)
    frow, fcol = from
    piece = game_board[frow][fcol]
    raise(InvalidMoveError, "No piece at #{from}") unless piece.is_a? ChessPiece

    raise(InvalidMoveError, "You cannot move opponent's piece at #{from}") unless piece.color == @current_player_color

    possible_moves = piece.possible_moves.to_a
    raise(InvalidMoveError, "You cannot move from #{from} to #{to}.") unless possible_moves.include?(to)

    trow, tcol = to
    to_space = @game_board[trow][tcol]
    if to_space.is_a? ChessPiece
      raise(InvalidMoveError, 'You cannot capture your own piece.') unless to_space.color != @current_player_color

      raise(InvalidMoveError, 'You cannot capture this piece.') unless piece.can_capture?(to, to_space)

      piece.position = [trow, tcol]
    end
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
      8.times { blank_rows << BLANK_SQUARE }
      rows << blank_rows
    end
    rows += place_pieces('black')

    rows
  end

  ##
  # Returns the 2 arrays of the chess pieces in the proper places based od
  # their color.
  def place_pieces(color)
    pawns = place_pawns(color)
    back_row_pieces = place_back_row(color)
    if color == 'white'
      [back_row_pieces, pawns]
    else
      [pawns, back_row_pieces]
    end
  end

  ##
  # Returns an array of pawns of the appropriate color on the
  # appropriate row based on +color+.
  def place_pawns(color)
    pawn_row = color == 'white' ? 1 : 6
    pawns = []
    8.times { |col| pawns << Pawn.new(color, [pawn_row, col]) }
    pawns
  end

  ##
  # Returns an array of back row pieces of the appropriate color
  # on the appropriate row based on +color+.
  def place_back_row(color)
    back_row = color == 'white' ? 0 : 7
    [Rook.new(color, [back_row, 0]),
     Knight.new(color, [back_row, 1]),
     Bishop.new(color, [back_row, 2]),
     Queen.new(color, [back_row, 3]),
     King.new(color, [back_row, 4]),
     Bishop.new(color, [back_row, 5]),
     Knight.new(color, [back_row, 6]),
     Rook.new(color, [back_row, 7])]
  end
end

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
# A chess game that contains the game board, rules,
# validation of moves, and computing check/checkmate.
class ChessGame
  WHITE_SQUARE = { background: :light_red }.freeze
  BLACK_SQAURE = { background: :red }.freeze
  BLANK_SQUARE = '  '

  ##
  # Creates instance variables and sets up the board for
  # the start of the game.
  def initialize
    @board = setup_board
    @current_player_color = 'white'
    @king_locs = { white: [0, 4], black: [7, 4] }
  end

  ##
  # Moves a piece at a given location to another location if
  # the move is valid. Raises an InvalidMoveError otherwise.
  #
  # +from+::  An integer array of length 2 denoting the position of the piece
  #           to move.
  # +to+::    An integer array of length 2 denoting the position to move the
  #           piece at +from+ to.
  def make_move(from, to)
    # Raises an execption if the move isn't valid
    validate_move(from, to)

    frow, fcol = from
    piece = @board[frow][fcol]
    trow, tcol = to

    # Capture a piece if the pawn performed En Passant
    @board[frow][tcol] = BLANK_SQUARE if piece.is_a?(Pawn) && get_en_passant_moves(piece).include?(to)

    # Move the piece on the board
    @board[trow][tcol] = piece.move(to)
    @board[frow][fcol] = BLANK_SQUARE

    @king_locs[@current_player_color.to_sym] = to if piece.is_a? King

    # Change whose turn it is
    change_turn
  end

  ##
  # Determines whether or not the move is a valid move. If the move is valid,
  # it returns that space on the board.
  # Raises an InvalidMoveError with a specific message if the move is invalid.
  #
  # +from+::  An integer array of length 2 denoting the position of the piece
  #           to move.
  # +to+::    An integer array of length 2 denoting the position to move the
  #           piece at +from+ to.
  def validate_move(from, to)
    frow, fcol = from
    piece = @board[frow][fcol]
    raise(InvalidMoveError, "No piece at #{from}") unless piece.is_a? ChessPiece

    raise(InvalidMoveError, "You cannot move opponent's piece at #{from}") unless piece.color == @current_player_color

    possible_moves = legal_moves(piece)
    raise(InvalidMoveError, "Your #{piece.class} cannot move from #{from} to #{to}.") unless possible_moves.include?(to)

    trow, tcol = to
    @board[trow][tcol]
  end

  ##
  # Returns an array of the legal moves that the piece can make.
  # This will prevent pieces from going through other pieces (except for the
  # knight, of course). It does so by iterating through +chess_piece+'s move
  # tree in level order, dequeing any nodes that are invalid.
  #
  # +chess_piece+:: The ChessPiece to find the legal moves of.
  def legal_moves(chess_piece)
    return pawn_legal_moves(chess_piece) if chess_piece.is_a? Pawn

    move_tree = chess_piece.possible_moves
    legal_moves_array = []
    visit_queue = move_tree.root.children
    until visit_queue.empty?
      current_node = visit_queue.shift
      row, col = current_node.loc
      space = @board[row][col]
      # If it's a chess piece, check if it can capture.
      if space.is_a? ChessPiece
        # If the piece can capture it, add it as a valid space, but don't
        # add any of its children to visit_queue.
        next unless chess_piece.can_capture?(space)
      else
        # If there's not piece, it can continue along the move tree.
        current_node.children.each { |child| visit_queue << child }
      end
      # Append legal move locations
      legal_moves_array << current_node.loc
    end
    legal_moves_array
  end

  ##
  # Returns an array of legal moves that a pawn can make. Since a pawn can only
  # move diagonally if it can capture a piece, it is its own special case.
  #
  # +pawn+:: The pawn to find the legal moves of.
  def pawn_legal_moves(pawn)
    # Assign the move tree for pawn
    pawn.possible_moves
    # Check if pawn can capture right diagonal piece
    r_diag = pawn.move_tree.root.children[1]
    l_diag = pawn.move_tree.root.children[2]

    unless r_diag.nil?
      r_diag_loc = r_diag.loc
      r_diag_piece = @board[r_diag_loc[0]][r_diag_loc[1]]
      pawn.move_tree.trim_branch!(r_diag_loc) unless pawn.can_capture?(r_diag_piece)
    end

    unless l_diag.nil?
      # Check if pawn can capture left diagonal piece
      l_diag_loc = l_diag.loc
      l_diag_piece = @board[l_diag_loc[0]][l_diag_loc[1]]
      pawn.move_tree.trim_branch!(l_diag_loc) unless pawn.can_capture?(l_diag_piece)
    end

    # Check if the two spaces ahead of an unmoved pawn is occupied
    unless pawn.move_tree.root.children[0].children.empty?
      front_loc = pawn.move_tree.root.children[0].children[0].loc
      front_piece = @board[front_loc[0]][front_loc[1]]
      pawn.move_tree.trim_branch!(front_loc) if front_piece.is_a? ChessPiece
    end

    # Check if there is a piece immediately in front of the pawn
    front_loc = pawn.move_tree.root.children[0].loc
    front_piece = @board[front_loc[0]][front_loc[1]]
    pawn.move_tree.trim_branch!(front_loc) if front_piece.is_a? ChessPiece

    pawn.move_tree.to_a + get_en_passant_moves(pawn)
  end

  ##
  # Returns an array of the valid En Passant moves for a given pawn
  #
  # +pawn+:: The pawn that is proposed to move.
  def get_en_passant_moves(pawn)
    # Check spaces beside the pawn for En Passant
    pawn_row, pawn_col = pawn.position
    r_piece_loc = [pawn_row + pawn.direction, pawn_col + 1]
    r_piece = @board[pawn_row][pawn_col + 1]

    l_piece_loc = [pawn_row + pawn.direction, pawn_col - 1]
    l_piece = @board[pawn_row][pawn_col - 1]
    en_passant_moves = []

    en_passant_moves << r_piece_loc if (r_piece.is_a? Pawn) && pawn.can_capture?(r_piece)

    en_passant_moves << l_piece_loc if (l_piece.is_a? Pawn) && pawn.can_capture?(l_piece)

    en_passant_moves
  end

  ##
  # Returns a string of a board with pieces and appropriately
  # shaded spaces.
  def to_s
    string_stream = StringIO.new
    8.downto(1) do |row|
      string_stream << " #{row} "
      @board[row - 1].each_with_index do |col, col_num|
        bg_color = (row - 1) % 2 == col_num % 2 ? BLACK_SQAURE : WHITE_SQUARE
        string_stream << col.to_s.colorize(bg_color)
      end
      string_stream << "\n"
    end

    string_stream << '   a b c d e f g h '

    string_stream.string
  end

  protected

  ##
  # Returns an array that sets the board up for the
  # start of the game.
  def setup_board
    # Build the empty board
    rows = place_pieces('white')
    rows += Array.new(4) { Array.new(8, BLANK_SQUARE) }
    rows += place_pieces('black')

    rows
  end

  ##
  # Returns the 2 arrays of the chess pieces in the proper places based od
  # their color.
  #
  # +color+:: A string denoting the color of pieces to place.
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
  #
  # +color+:: A string denoting the color of pawns to place.
  def place_pawns(color)
    pawn_row = color == 'white' ? 1 : 6
    pawns = []
    8.times { |col| pawns << Pawn.new(color, [pawn_row, col]) }
    pawns
  end

  ##
  # Returns an array of back row pieces of the appropriate color
  # on the appropriate row based on +color+.
  #
  # +color+:: A string denoting the color of pieces to place.
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

  ##
  # Changes whose turn it is by switching between 'black' and 'white'.
  def change_turn
    @current_player_color = @current_player_color == 'white' ? 'black' : 'white'
  end
end

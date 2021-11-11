# frozen_string_literal: true

require_relative 'chess_piece'
require_relative 'queen'
require_relative 'rook'
require_relative 'bishop'
require_relative 'knight'

##
# Pawn piece for a game of chess
class Pawn < ChessPiece
  attr_reader :direction
  attr_accessor :move_count

  ##
  # Initializes a new pawn piece with color and position.
  #
  # @param [String]         color     A string denoting the color of the piece.
  # @param [Array<Integer>] position  An integer array of length 2 denoting the
  #                                   location of the piece on the board.
  def initialize(color, position)
    @move_count = 0
    @direction = color == 'white' ? 1 : -1
    @back_row = color == 'white' ? 7 : 0
    @move_tree_template = build_pawn_move_tree
    super(color == 'white' ? '♙' : '♙', color, position, 1)
  end

  ##
  # Possible moves rewrite for the pawn
  def possible_moves
    # Remove the two space move on the Pawn's first move
    @move_tree_template = @move_count.zero? ? build_pawn_move_tree_first_move : build_pawn_move_tree
    super
  end

  ##
  # Moves the Pawn and updates @move_count
  # If the pawn reaches the back row of the opposing side, it returns a queen.
  #
  # @param [Array<Integer>] An integer array of length 2 denoting the new
  #                         location of the pawn.
  # @param [String] The type of player whose pawn it is. Used mainly for pawn
  #                 promotion.
  #
  # @return [ChessPiece] A pawn if the pawn moves or a Queen if the pawn
  #                         reaches the end of the board.
  def move(to, player_type = 'human')
    @move_count += 1

    if to[0] == @back_row
      piece_type = new_piece_type(player_type)
      # Pawn becomes a new piece
      return piece_type.new(@color, to)
    end

    super(to)
  end

  ##
  # Returns whether or not the move the Pawn is on or just finished
  # its first ever move.
  #
  # @return [true] if the pawn is on or just finished its first move.
  def first_move?
    @move_count <= 1
  end

  ##
  # Returns whether the pawn can capture a piece at a given location
  # based on its current position. This only possible if the opposing
  # piece is in front of and diagonal to the current space.
  #
  # @param [ChessPiece] other_piece The ChessPiece that is the proposed target.
  # @return [true] if pawn can capture the piece.
  def can_capture?(other_piece)
    return false unless other_piece.is_a? ChessPiece

    return false if other_piece.color == @color

    occupied_position = other_piece.position
    in_front = occupied_position[0] == (@position[0] + @direction)
    diagonal = [@position[1] + 1, @position[1] - 1].include?(occupied_position[1])
    in_front && diagonal || en_passant(other_piece)
  end

  protected

  ##
  # Prompt the user for input to determine what piece to return when the pawn
  # advances to the last square
  #
  # @param [String] The type of player whose pawn it is. Used mainly for pawn
  #                 promotion.
  #
  # @return [Class] The type of piece the pawn is turning into.
  def new_piece_type(player_type = 'human')
    case player_type
    when 'human'
      puts 'Your pawn is being promoted! What peice would you like it to become?'
      print_piece_types
      player_input = $stdin.gets
      player_input = player_input&.chomp
      player_input = player_input&.downcase
    when 'random'
      player_input = %w[1 2 3 4].sample
    else
      player_input = '1'
    end

    return Queen if %w[1 queen q].include?(player_input)

    return Rook if %w[2 rook r].include?(player_input)

    return Bishop if %w[3 bishop b].include?(player_input)

    return Knight if %w[4 knight k].include?(player_input)

    raise(StandardError, "'#{player_input}' is not a valid input.")
  rescue StandardError => e
    puts e.message
    puts 'Please select an option from the menu.'
    retry
  end

  ##
  # Prints the menu for pieces the pawn can become.
  def print_piece_types
    puts <<~PAWN_MENU
      Please select one of the following options:
      1. Queen (Q) ♛     3. Bishop (B) ♝
      2. Rook (R) ♜      4. Knight (K) ♞

      You may use the number, letter, or name to select the piece.
      e.g - "1", "Queen", or "Q" all select the queen.
    PAWN_MENU
  end

  ##
  # Returns whether the Pawn can capture another Pawn using the rule
  # "En passant."
  # See {the Wikipeida entry}[https://en.wikipedia.org/wiki/En_passant].
  #
  # @param [ChessPiece] other_piece The ChessPiece that is the proposed target.
  # @return [true] if the other piece is a capturable pawn using En Passant.
  def en_passant(other_piece)
    # Only applies to other Pawns
    return false unless other_piece.is_a? Pawn

    # Only applies when the other Pawn just finished its first move
    return false unless other_piece.first_move?

    # Check beside on the right
    beside = other_piece.position == [@position[0], @position[1] + 1]
    # Check beside on the left
    beside || (other_piece.position == [@position[0], @position[1] - 1])
  end

  ##
  # Builds the Pawn move tree. The pawn can move forward 2 spaces on its first
  # move, but otherwise can only move one space forward. The Pawn may also move
  # diagonally to capture an enemy piece.
  #
  # @return [MoveTree] move_tree_template A move tree template for the pawn.
  def build_pawn_move_tree_first_move
    move_tree = MoveTree.new([0, 0])

    # Create changes based on @direction because pawns can only move one
    # direction.
    move_tree.root.add_child([@direction, 0])
    move_tree.root.children[0].add_child([2 * @direction, 0])
    move_tree.root.add_child([@direction, 1])
    move_tree.root.add_child([@direction, -1])

    move_tree
  end

  ##
  # Builds the Pawn move tree without the two-space forward move.
  # The pawn can move forward 2 spaces on its first move, but otherwise can
  # only move one space forward. The Pawn may also move diagonally to capture
  # an enemy piece.
  #
  # @return [MoveTree] move_tree_template A move tree template for the pawn.
  def build_pawn_move_tree
    move_tree = MoveTree.new([0, 0])

    # Create changes based on @direction because pawns can only move one
    # direction.
    move_tree.root.add_child([@direction, 0])
    move_tree.root.add_child([@direction, 1])
    move_tree.root.add_child([@direction, -1])

    move_tree
  end
end

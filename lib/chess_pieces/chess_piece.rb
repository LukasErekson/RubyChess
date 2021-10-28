# frozen_string_literal: true

require 'colorize'
require_relative 'move_tree'

##
# An abstract class for a chess piece (pawn, king, rook, etc.)
class ChessPiece
  include Comparable
  attr_reader :name, :color, :position, :points, :move_tree

  ##
  # Initializes a piece with its name, color, position, and score.
  #
  # @param [String]         name      The name of the piece.
  # @param [String]         color     What side the piece is on.
  # @param [Array<Integer>] position  An array of length two representing the
  #                                   row and column ([row, col]).
  # @param [Integer]        points    An integer indicating how many points
  #                                   the piece is worth.
  def initialize(name, color, position, points)
    @name = name
    @color = color
    @position = position
    @points = points
    @move_tree = MoveTree.new(position)
  end

  ##
  # Updates position to be the +to+. Returns the piece with the updated
  # location.
  #
  # @param [Array<Integer>] to An integer array of length 2 denoting the new
  #                            location of the piece.
  # @return [ChessPiece]
  def move(to)
    @position = to
    self
  end

  ##
  # Returns a move tree of legal move positions.
  #
  # This method takes the @move_tree_template and @position attributes and
  # uses them to create a new MoveTree object with the exact coordinates.
  #
  # @return [MoveTree] A move tree of moves based on the current position that
  #                    are currently in bounds.
  def possible_moves
    row, col = @position
    @move_tree = @move_tree_template.clone || move_tree
    @move_tree.each do |node|
      r, c = node.loc
      potential_space = [row + r, col + c]
      node.loc = potential_space
    end

    move_tree_in_bounds
  end

  ##
  # Returns and assigns @move_tree with all moves in bounds
  #
  # @return[MoveTree] A move tree of moves that are within the bounds of the
  #                   8 x 8 chess board.
  def move_tree_in_bounds
    @move_tree.each do |node|
      @move_tree.trim_branch!(node) unless node.loc.all? { |coord| coord.between?(0, 7) }
    end

    @move_tree
  end

  ##
  # Returns whether the piece can capture another piece given its position.
  #
  # @param [ChessPiece] other_piece The ChessPiece that is the proposed target.
  # @return [true] if self can move there (overridden by the Pawn class)
  def can_capture?(other_piece)
    return true unless other_piece.is_a? ChessPiece

    return false if other_piece.color == @color

    # Most pieces can capture if they can move there. Pawns are the exception.
    possible_moves.to_a.include?(other_piece.position)
  end

  ##
  # Returns the name of the piece with a space after it.
  #
  # @return [String] The name of the piece of its color with a space after it.
  def to_s
    "#{@name} ".colorize(color: @color.to_sym)
  end

  ##
  # Add children to move tree nodes such that each move is a child node of
  # the move that precedes it.
  #
  # @param [Array<Integer>] direction An array of integers of length 2
  #                                   indicating the movement in
  #                                   the vertical and horizontal net changes.
  #                                   For just vertical movement, direction is
  #                                   [1, 0]. For diagonal moves, it's [1, 1].
  # @return [MoveTreeNode] The MoveTreeNode that has as its children all the
  #                        spaces in the given direction.
  def build_directional_tree_nodes(direction = [1, 0])
    vertical_movement, horizontal_movement = direction
    closest_move = MoveTreeNode.new(direction)
    (2..7).each do |spaces|
      current_child = closest_move
      (spaces - 2).times { current_child = current_child.children[0] }
      current_child.add_child([spaces * vertical_movement, spaces * horizontal_movement])
    end

    closest_move
  end

  ##
  # Compare pieces based on their point values.
  # Note: Since Bishop and Knight point values are equal, it returns -1 if
  #       this piece is a knight and 1 if this piece is a bishop. This is an
  #       arbitrary choice to differentiate them.
  #
  # @param [ChessPiece] other The ChessPiece object to compare against self.
  # @returns [Integer] 0 if the pieces are equal in point values, 1 if self has
  #                    a greater point value, and -1 otherwise.
  def <=>(other)
    return nil unless other.is_a? ChessPiece

    value_comparison = @points <=> other.points
    return value_comparison unless value_comparison.zero? && @points == 3

    pieces = [@name, other.name].sort

    both_knights = ['♞'.white, '♘'].repeated_combination(2).any? { |combo| pieces == combo }
    both_bishops = ['♝'.white, '♗'].repeated_combination(2).any? { |combo| pieces == combo }

    return 0 if both_knights || both_bishops

    return -1 if (@name == '♞'.white) || (@name == '♘')

    # This piece is a bishop and the other is a knight, so return 1.
    1
  end
end

# frozen_string_literal: true

require_relative 'move_tree'

##
# An abstract class for a chess piece (pawn, king, rook, etc.)
class ChessPiece
  attr_reader :name, :color, :position, :points, :move_tree

  ##
  # Initializes a piece with its name, color, position, and score.
  #
  # +name+::      The name of the piece
  # +color+::     What side the piece is on
  # +position+::  An array of length two [row, col]
  # +points+::    An integer indicating how many points the piece is worth
  def initialize(name, color, position, points)
    @name = name
    @color = color
    @position = position
    @points = points
    @move_tree = MoveTree.new(position)
  end

  ##
  # Updates position to be the +to+. Returns the piece with the updated
  # location
  def move(to)
    @position = to
    self
  end

  ##
  # Returns a move tree of legal move positions
  def possible_moves
    row, col = @position
    @move_tree = @move_tree_template.clone || move_tree
    @move_tree.each do |node|
      r, c = node.loc
      node.loc = [row + r, col + c]
    end

    @move_tree = moves_in_bounds
  end

  ##
  # Returns whether the piece can capture another piece given its position
  def can_capture?(other_piece)
    unless other_piece.is_a? ChessPiece
      raise(ArgumentError, "other_piece is a #{other_piece.class}, but it must be a ChessPiece.")
    end

    # Most pieces can capture if they can move there. Pawns are the exception.
    @move_tree.to_a.include?(other_piece.position)
  end

  ##
  # Returns the name of the piece with a space after it
  def to_s
    "#{@name} "
  end

  ##
  # Filters move tree, eliminating any that are outside
  # a typical 8 x 8 chess board.
  def moves_in_bounds
    @move_tree.each do |node|
      node.children.each do |child|
        node.remove_child(child) unless child.loc.all? { |coordinate| coordinate.between?(0, 7) }
      end
    end

    @move_tree
  end
end

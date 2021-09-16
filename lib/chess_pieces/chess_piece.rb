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
  # Returns an array of legal move positions
  def legal_moves
    raise StandardError, 'Overwrite for each piece'
  end

  ##
  # Returns whether the piece can capture another piece given its position
  def can_capture?(_occupied_position)
    raise StandardError, 'Overwrite for each piece'
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
        unless child.loc.all? { |coordinate| coordinate.between?(0, 7) }
          node.children.delete(child)
        end
      end
    end

    @move_tree
  end
end

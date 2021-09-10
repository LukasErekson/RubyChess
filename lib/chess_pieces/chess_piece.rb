# frozen_string_literal: true

##
# An abstract class for a chess piece (pawn, king, rook, etc.)
class ChessPiece
  attr_reader :name, :color, :position, :points

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
  end

  ##
  # Returns an array of legal move positions
  def legal_moves
    raise StandardError.new('Overwrite for each piece')
  end

  ##
  # Returns whether the piece can capture another piece given its position
  def can_capture?(occupied_position)
    raise StandardError.new('Overwrite for each piece')
  end

  ##
  # Returns the name, color, and location as as a string
  def to_s
    "#{@color} #{@name} at #{@position}"
  end

  ##
  # Filters an array of moves, eliminating any that are outside
  # a typical 8 x 8 chess board.
  def moves_in_bounds(move_arr)
    move_arr.select { |position| position.all? { |coordinate| coordinate.between?(0, 7) } }
  end
end

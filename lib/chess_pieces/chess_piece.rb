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
  def legal_moves(board)
    raise 'Overwrite for each piece'
  end

  ##
  # Returns whether the piece can capture another piece given its position
  def can_capture?(occupied_position)
    raise 'Overwrite for each piece'
  end

  ##
  # Returns the name, color, and location as as a string
  def to_s
    "#{@color} #{@name} at #{@position}"
  end
end

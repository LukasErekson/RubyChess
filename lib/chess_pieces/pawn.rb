# frozen_string_literal: true

require_relative 'chess_piece'

##
# Pawn piece for chess
class Pawn < ChessPiece
  attr_reader :has_moved, :direction

  ##
  # Initializes a new pawn
  def initialize(color, position)
    @has_moved = false
    @direction = color == 'white' ? 1 : -1
    super(color == 'white' ? '♙' : '♟', color, position, 1)
  end

  ##
  # Returns an array of legal move positions based on the
  # current position.
  def legal_moves
    row, col = @position
    legal_move_arr = []
    (-1..1).each { |val| legal_move_arr.append([row + @direction, col + val]) }

    # A pawn may travel two spaces in the given direction unless it
    # has already moved before.
    legal_move_arr.append([row + 2 * @direction, col]) unless @has_moved

    moves_in_bounds(legal_move_arr)
  end

  ##
  # Returns whether the pawn can capture a piece at a given location
  # based on its current position. This only possible if the opposing
  # piece is in front of and diagonal to the current space.
  #
  # TODO: Implement Empassan(sp?)
  def can_capture?(occupied_position, other_piece)
    return false if other_piece.color == @color

    in_front = occupied_position[0] == (@position[0] + @direction)
    diagonal = [@position[1] + 1, @position[1] - 1].include?(occupied_position[1])
    in_front && diagonal
  end

  # Flags @has_moved as true, indicating that the pawn can no
  # longer move two spaces ahead of its current position.
  def moved
    @has_moved = true
  end
end

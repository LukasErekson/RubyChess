# frozen_string_literal: true

require_relative 'chess_piece'

class Bishop < ChessPiece
<<<<<<< HEAD
=======

>>>>>>> f51bab81f3a52469847f51a7475e35268837134b
  ##
  # Initializes a new pawn
  def initialize(color, position)
    super(color == 'white' ? '♝'.white : '♗', color, position, 3)
  end
end

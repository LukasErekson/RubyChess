# frozen_string_literal: true

require_relative 'chess_piece'

class Queen < ChessPiece

  ##
  # Initializes a new pawn
  def initialize(color, position)
    super(color == 'white' ? '♛'.white : '♕', color, position, 9)
  end
end

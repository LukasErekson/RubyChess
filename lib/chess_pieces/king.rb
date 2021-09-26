# frozen_string_literal: true

require_relative 'chess_piece'

class King < ChessPiece

  ##
  # Initializes a new pawn
  def initialize(color, position)
    super(color == 'white' ? '♚'.white : '♔', color, position, 10_000)
  end
end

# frozen_string_literal: true

require_relative 'chess_piece'

class King < ChessPiece
  attr_reader :direction

  ##
  # Initializes a new pawn
  def initialize(color, position)
    super(color == 'white' ? '♚'.white : '♔', color, position, 10_000)
  end
end

# frozen_string_literal: true

require_relative 'chess_piece'

class Knight < ChessPiece
  attr_reader :direction

  ##
  # Initializes a new pawn
  def initialize(color, position)
    @direction = color == 'white' ? 1 : -1
    super(color == 'white' ? '♞'.white : '♘', color, position, 3)
  end
end

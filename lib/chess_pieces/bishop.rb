# frozen_string_literal: true

require_relative 'chess_piece'

##
# Bishop piece for a game of chess
class Bishop < ChessPiece
  ##
  # Initializes a new pawn
  def initialize(color, position)
    super(color == 'white' ? '♝'.white : '♗', color, position, 3)
  end
end

# frozen_string_literal: true

require_relative 'chess_piece'

##
# Queen piece for a game of chess
class Queen < ChessPiece
  ##
  # Initializes a new pawn
  def initialize(color, position)
    super(color == 'white' ? '♛'.white : '♕', color, position, 9)
  end
end

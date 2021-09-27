# frozen_string_literal: true

require_relative 'chess_piece'

##
# King piece for a gameof chess
class King < ChessPiece
  ##
  # Initializes a new pawn
  def initialize(color, position)
    @move_tree_template = build_king_move_tree
    super(color == 'white' ? '♚'.white : '♔', color, position, 10_000)
  end

  protected

  ##
  # Builds a king move tree where the king can move in any direction up to
  # one space.
  def build_king_move_tree
    move_tree_template = MoveTree.new([0, 0])

    # Get the 8 surrounding spaces
    locations = [-1, 0, 1].repeated_permutation(2).to_a
    locations.delete([0, 0])

    locations.each do |loc|
      move_tree_template.root.add_child(loc)
    end

    move_tree_template
  end
end

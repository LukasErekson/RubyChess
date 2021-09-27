# frozen_string_literal: true

require_relative 'chess_piece'

##
# Knight piece for a game of chess
class Knight < ChessPiece
  ##
  # Initializes a new pawn
  def initialize(color, position)
    @move_tree_template = build_knight_move_tree
    super(color == 'white' ? '♞'.white : '♘', color, position, 3)
  end

  ##
  # Builds the Knight move tree. The Knight can move in an L shape in any
  # direction as long as the board permits. The permutations given represent
  # the 8 spaces a Knight may move to.
  def build_knight_move_tree
    move_tree = MoveTree.new([0, 0])
    # Get all possible net changes for a knight
    knight_moves_delta = [1, -1, 2, -2].permutation(2).reject { |n| n.sum.zero? }
    knight_moves_delta.each { |move| move_tree.root.add_child(move) }

    move_tree
  end
end

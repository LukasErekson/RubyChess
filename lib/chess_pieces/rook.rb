# frozen_string_literal: true

require_relative 'chess_piece'

class Rook < ChessPiece
  ##
  # Initializes a new pawn
  def initialize(color, position)
    @move_tree_template = build_rook_move_tree
    super(color == 'white' ? '♜'.white : '♖', color, position, 5)
  end

  protected

  ##
  # Buildsthe rook's template build tree
  def build_rook_move_tree
    move_tree = MoveTree.new([0, 0])

    # Build in each of the four directions the rook can go.
    move_tree.root.add_child(build_directional_tree_nodes([1, 0]))
    move_tree.root.add_child(build_directional_tree_nodes([-1, 0]))
    move_tree.root.add_child(build_directional_tree_nodes([0, 1]))
    move_tree.root.add_child(build_directional_tree_nodes([0, -1]))

    move_tree
  end
end

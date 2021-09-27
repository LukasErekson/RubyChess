# frozen_string_literal: true

require_relative 'chess_piece'

##
# Bishop piece for a game of chess
class Bishop < ChessPiece
  ##
  # Initializes a new pawn
  def initialize(color, position)
    @move_tree_template = build_bishop_move_tree
    super(color == 'white' ? '♝'.white : '♗', color, position, 3)
  end

  protected

  ##
  # Build a bishop's move tree with only diagonal moves.
  def build_bishop_move_tree
    move_tree_template = MoveTree.new([0, 0])

    move_tree_template.root.add_child(build_directional_tree_nodes([1, 1]))
    move_tree_template.root.add_child(build_directional_tree_nodes([-1, 1]))
    move_tree_template.root.add_child(build_directional_tree_nodes([1, -1]))
    move_tree_template.root.add_child(build_directional_tree_nodes([-1, -1]))

    move_tree_template
  end
end

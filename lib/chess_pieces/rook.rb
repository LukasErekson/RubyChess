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
  # Add children to move tree nodes such that each move is a child node of
  # the move that precedes it.
  def build_directional_tree_nodes(direction = [1, 0])
    vertical_movement, horizontal_movement = direction
    closest_move = MoveTreeNode.new(direction)
    (2..8).each do |spaces|
      current_child = closest_move
      (spaces - 2).times { current_child = current_child.children[0] }
      current_child.add_child([spaces * vertical_movement, spaces * horizontal_movement])
    end

    closest_move
  end

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

# frozen_string_literal: true

require_relative 'chess_piece'

##
# Bishop piece for a game of chess
class Bishop < ChessPiece
  ##
  # Initializes a new bishop piece with color and position.
  #
  # +color+::     A string denoting the color of the piece.
  # +position+::  An integer array of length 2 denoting the location of the
  #               piece on the board.
  def initialize(color, position)
    @move_tree_template = build_bishop_move_tree
    super(color == 'white' ? '♝'.white : '♗', color, position, 3)
  end

  protected

  ##
  # Builds a Bishop's move tree. The Bishop can move diagonally as far as the
  # board permits.
  def build_bishop_move_tree
    move_tree_template = MoveTree.new([0, 0])

    move_tree_template.root.add_child(build_directional_tree_nodes([1, 1]))
    move_tree_template.root.add_child(build_directional_tree_nodes([-1, 1]))
    move_tree_template.root.add_child(build_directional_tree_nodes([1, -1]))
    move_tree_template.root.add_child(build_directional_tree_nodes([-1, -1]))

    move_tree_template
  end
end

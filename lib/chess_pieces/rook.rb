# frozen_string_literal: true

require_relative 'chess_piece'

##
# Rook piece for a game of chess
class Rook < ChessPiece
  ##
  # Initializes a new rook piece with color and position.
  #
  # @param [String]         color     A string denoting the color of the piece.
  # @param [Array<Integer>] position  An integer array of length 2 denoting the
  #                                   location of the piece on the board.
  def initialize(color, position)
    @move_tree_template = build_rook_move_tree
    super(color == 'white' ? '♜'.white : '♖', color, position, 5)
  end

  # TODO : Allow Rooks and Kings to castle under the right conditions

  protected

  ##
  # Builds the Rook's move tree. The Rook can move horizontally and vertically
  # as far as the board permits.
  #
  # @return [MoveTree] move_tree_template A move tree template for the rook.
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

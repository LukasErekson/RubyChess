# frozen_string_literal: true

require_relative 'chess_piece'

##
# Queen piece for a game of chess
class Queen < ChessPiece
  ##
  # Initializes a new queen piece with color and position.
  #
  # @param [String]         color     A string denoting the color of the piece.
  # @param [Array<Integer>] position  An integer array of length 2 denoting the
  #                                   location of the piece on the board.
  def initialize(color, position)
    @move_tree_template = build_queen_move_tree
    super(color == 'white' ? '♛'.white : '♕', color, position, 9)
  end

  protected

  ##
  # Builds the Queen's move tree. The Queen can move in any direction as far as
  # the board permits.
  #
  # @return [MoveTree] move_tree_template A move tree template for the Queen.
  def build_queen_move_tree
    move_tree_template = MoveTree.new([0, 0])
    # Get directions
    directions = [-1, 0, 1].repeated_permutation(2).to_a
    directions.delete([0, 0])

    directions.each do |direction|
      move_tree_template.root.add_child(build_directional_tree_nodes(direction))
    end

    move_tree_template
  end
end

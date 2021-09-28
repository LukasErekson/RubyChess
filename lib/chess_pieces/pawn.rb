# frozen_string_literal: true

require_relative 'chess_piece'
require_relative 'queen'

##
# Pawn piece for a game of chess
class Pawn < ChessPiece
  attr_reader :move_count, :direction

  ##
  # Initializes a new pawn
  def initialize(color, position)
    @move_count = 0
    @direction = color == 'white' ? 1 : -1
    @back_row = color == 'white' ? 7 : 0
    @move_tree_template = build_pawn_move_tree
    super(color == 'white' ? '♟'.white : '♙', color, position, 1)
  end

  ##
  # Moves the Pawn and updates @move_count
  # If the pawn reaches the back row of the opposing side, it returns a queen.
  def move(to)
    # Remove the two space move on the Pawn's first move
    @move_tree_template.root.children[0].children.pop if @move_count.zero?

    @move_count += 1

    # Pawn becomes a queen
    return Queen.new(@color, to) if to[0] == @back_row

    super(to)
  end

  ##
  # Returns whether or not the move the Pawn is on is its first ever move.
  def first_move?
    @move_count <= 1
  end

  ##
  # Returns whether the pawn can capture a piece at a given location
  # based on its current position. This only possible if the opposing
  # piece is in front of and diagonal to the current space.
  def can_capture?(other_piece)
    occupied_position = other_piece.position
    in_front = occupied_position[0] == (@position[0] + @direction)
    diagonal = [@position[1] + 1, @position[1] - 1].include?(occupied_position[1])
    in_front && diagonal || en_passant(other_piece)
  end

  protected

  ##
  # Returns whether the Pawn can capture another Pawn using the rule
  # "En passant."
  # See https://en.wikipedia.org/wiki/En_passant
  def en_passant(other_piece)
    # Only applies to other Pawns
    return false unless other_piece.is_a? Pawn

    # Only applies when the other Pawn just finished its first move
    return false unless other_piece.first_move?

    # Check beside on the right
    beside = other_piece.position == [@position[0], @position[1] + 1]
    # Check beside on the left
    beside || (other_piece.position == [@position[0], @position[1] - 1])
  end

  ##
  # Builds the Pawn move tree. The pawn can move forward 2 spaces on its first
  # move, but otherwise can only move one space forward. The Pawn may also move
  # diagonally to capture an enemy piece.
  def build_pawn_move_tree
    move_tree = MoveTree.new([0, 0])

    # Create changes based on @direction because pawns can only move one
    # direction.
    move_tree.root.add_child([@direction, 0])
    move_tree.root.children[0].add_child([2 * @direction, 0])
    move_tree.root.add_child([@direction, 1])
    move_tree.root.add_child([@direction, -1])

    move_tree
  end
end

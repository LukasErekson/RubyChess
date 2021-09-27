# frozen_string_literal: true

require_relative 'chess_piece'
require_relative 'queen'

##
# Pawn piece for a game of chess
class Pawn < ChessPiece
  attr_reader :has_moved, :direction

  ##
  # Initializes a new pawn
  def initialize(color, position)
    @has_moved = false
    @direction = color == 'white' ? 1 : -1
    @back_row = color == 'white' ? 7 : 0
    @move_tree_template = build_pawn_move_tree
    super(color == 'white' ? '♟'.white : '♙', color, position, 1)
  end

  ##
  # Moves the pawn and updates +@has_moved+.
  # If the pawn reaches the back row of the opposing side,
  # it returns a queen.
  def move(to)
    moved unless @has_moved

    # Pawn becomes a queen
    return Queen.new(@color, to) if to[0] == @back_row

    super(to)
  end

  ##
  # Returns whether the pawn can capture a piece at a given location
  # based on its current position. This only possible if the opposing
  # piece is in front of and diagonal to the current space.
  #
  # TODO: Implement Empassan(sp?)
  def can_capture?(other_piece)
    unless other_piece.is_a? ChessPiece
      raise(ArgumentError, "other_piece is a #{other_piece.class}, but it must be a ChessPiece.")
    end

    return false if other_piece.color == @color

    occupied_position = other_piece.position
    in_front = occupied_position[0] == (@position[0] + @direction)
    diagonal = [@position[1] + 1, @position[1] - 1].include?(occupied_position[1])
    in_front && diagonal
  end

  # Flags @has_moved as true, indicating that the pawn can no
  # longer move two spaces ahead of its current position.
  def moved
    @has_moved = true
    @move_tree_template.root.children[0].children.pop
  end

  protected

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

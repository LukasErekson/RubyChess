# frozen_string_literal: true

require_relative 'move_tree_node'

##
# A tree structure for the possible moves of a chess piece.
class MoveTree
  include Enumerable
  attr_reader :root

  ##
  # Assigns a MoveTreeNode to be the root.
  #
  # @param [Array<Integer>] root_position An integer array of length 2
  #                                       representing the starting location
  #                                       for a piece.
  def initialize(root_position)
    @root = MoveTreeNode.new(root_position)
  end

  ##
  # Iterates through the tree using level order.
  #
  # @param [Block or Proc] The block to call each node in the the tree on.
  def each(&block)
    visit_queue = [@root]
    until visit_queue.empty?
      current_node = visit_queue.shift
      block.call(current_node)
      current_node.children.each { |child| visit_queue << child }
    end
    self
  end

  ##
  # Creates a deep copy of the move tree.
  #
  # @return [MoveTree] A deep copy of self.
  def clone
    Marshal.load(Marshal.dump(self))
  end

  ##
  # Removes a node and its children from the MoveTree.
  # Returns the trimmed child if it was found and nil if it wasn't found in the
  # tree.
  #
  # @param [Array<Integer>] loc  A location array (2 integers) or a MoveTreeNode
  #                              to remove from the the tree.
  # @raise [ArgumentError] if +loc+ is not an Array or MoveTreeNode.
  def trim_branch!(loc)
    # Raise an error if the argument is not either an array or a MoveTreeNode
    unless (loc.is_a? Array) || (loc.is_a? MoveTreeNode)
      raise(ArgumentError, "Argument is a #{loc.class}; should be Array or MoveTreeNode")
    end

    # Convert loc to an array so that node.children.include?(loc) can
    # find the right node.
    loc = loc.is_a?(Array) ? loc : loc.loc

    each do |node|
      children_arr = node.children.map(&:loc)
      if children_arr.include?(loc)
        node.remove_child(loc)
        return loc
      end
    end

    # Return nothing if the node was not found.
    nil
  end

  ##
  # Returns an array of the Move Tree using level order
  # (for ease of writing test cases)
  #
  # @return [Array<Array<Integer>>] tree_array The array of locations of the
  #                                            move tree.
  def to_a
    tree_array = []
    each { |node| tree_array << node.loc }
    # Remove the root node since staying in the same location
    # is not a move.
    tree_array.shift
    tree_array
  end
end

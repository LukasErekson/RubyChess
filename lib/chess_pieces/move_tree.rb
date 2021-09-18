# frozen_string_literal: true

require_relative 'move_tree_node'

##
# A tree structure for the possible moves of a piece
class MoveTree
  include Enumerable
  attr_reader :root

  ##
  # Assigns a MoveTreeNode to be the root
  def initialize(root_position)
    @root = MoveTreeNode.new(root_position)
  end

  ##
  # Iterates through the tree using level order
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
  # Creates a deep copy of the move tree
  def clone
    Marshal.load(Marshal.dump(self))
  end

  ##
  # Returns an array of the Move Tree using level order
  # (for ease of writing test cases)
  def to_a
    tree_array = []
    each { |node| tree_array << node.loc }
    # Remove the root node since staying in the same location
    # is not a move.
    tree_array.shift
    tree_array
  end
end

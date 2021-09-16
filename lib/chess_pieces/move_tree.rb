# frozen_string_literal: true

require_relative 'move_tree_node'

##
# A tree structure for the possible moves of a piece
class MoveTree
  include Enumerable
  attr_reader :root

  ##
  # Assign a MoveTreeNode to be the root
  def initialize(root_position)
    @root = MoveTreeNode.new(root_position)
  end

  ##
  # Iterate through the tree using breadth-first
  def each(&block)
    visit_queue = [@root]
    until visit_queue.empty?
      current_node = visit_queue.shift
      current_node.children.each { |child| visit_queue << child }
      block.call(current_node)
    end
  end

  ##
  # Creates a deep copy of the move tree
  def clone
    Marshal.load( Marshal.dump(self) )
  end

  ##
  # Returns an array of the Move Tree using level order
  # (for ease of writing test cases)
  def to_a
    # return [@loc] if @children.empty?

    # tree_array = []
    # @children.each do |child|
    #   puts child
    #   tree_array += child.to_a
    # end
    # tree_array
    tree_array = []
    each { |node| tree_array << node.loc }

    # Skip root node
    tree_array[1..]
  end
  

end
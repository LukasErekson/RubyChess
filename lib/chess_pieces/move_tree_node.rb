# frozen_string_literal: true

##
# A node structure for the tree representation of a pieces potential moves.
class MoveTreeNode
  attr_accessor :loc, :children

  def initialize(loc)
    @loc = loc
    @children = []
  end

  ##
  # Add a child to the list of children nodes
  def add_child(loc)
    return @children << MoveTreeNode.new(loc) if loc.is_a? Array

    return @children << loc if loc.is_a? MoveTreeNode

    raise(StandardError, "Argument is a #{loc.class}; should be Array or MoveTreeNode")
  end

  ##
  # Returns an array of the Move Tree using in-order
  # (for ease of writing test cases)
  def to_a
    return [@loc] if @children.empty?

    tree_array = []
    @children.each do |child|
      puts child
      tree_array += child.to_a
    end
    tree_array
  end

  def to_s
    "#{@loc}: #{@children}"
  end
end

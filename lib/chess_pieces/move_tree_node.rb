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

    # Raise an error if the argument is not either an array or a MoveTreeNode
    raise(ArgumentError, "Argument is a #{loc.class}; should be Array or MoveTreeNode")
  end

  ##
  # Returns a astring representation of the node using its location
  # and a list of its children.
  def to_s
    "#{@loc}: #{@children}"
  end
end

# frozen_string_literal: true

##
# A node structure for the tree representation of a pieces potential moves.
# See MoveTree.
class MoveTreeNode
  attr_accessor :loc
  attr_reader :children

  ##
  # Initialize a node with its location and an empty children array.
  #
  # +loc+:: An integer array of length 2 denoting the location the node
  #         represents.
  def initialize(loc)
    @loc = loc
    @children = []
  end

  ##
  # Add a child to the array of children nodes.
  #
  # +loc+:: Either an integer array of length 2 denoting the location of the
  #         node to add or the MoveTreeNode to add.
  def add_child(loc)
    return @children << MoveTreeNode.new(loc) if loc.is_a? Array

    return @children << loc if loc.is_a? MoveTreeNode

    # Raise an error if the argument is not either an array or a MoveTreeNode
    raise(ArgumentError, "Argument is a #{loc.class}; should be Array or MoveTreeNode")
  end

  ##
  # Removes a child from the array of children nodes.
  #
  # +loc+ :: Either an integer array of length 2 denoting the location of the
  #          node to remove or the MoveTreeNode to remove.
  def remove_child(loc)
    return @children.delete(MoveTreeNode.new(loc)) if loc.is_a? Array

    return @children.delete(loc) if loc.is_a? MoveTreeNode

    # Raise an error if the argument is not either an array or a MoveTreeNode
    raise(ArgumentError, "Argument is a #{loc.class}; should be Array or MoveTreeNode")
  end

  ##
  # Returns a astring representation of the node using its location
  # and a list of its children.
  def to_s
    "#{@loc}: #{@children}"
  end

  ##
  # Define equality between two nodes by same location.
  #
  # +other+:: The other MoveTreeNode to compare the location for equality.
  def ==(other)
    return false unless other.is_a? MoveTreeNode

    @loc == other.loc
  end
end

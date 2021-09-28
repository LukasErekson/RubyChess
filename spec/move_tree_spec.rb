# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/move_tree_node'
require_relative '../lib/chess_pieces/move_tree'

RSpec.describe MoveTree do
  let(:move_tree) { described_class.new([1, 1]) }

  describe '#clone' do
    it 'creates a deep copy of the tree' do
      move_tree2 = move_tree.clone
      # Modifying the clone should not affect the original
      expect(proc { move_tree2.root.add_child([1, 2]) }).not_to change(move_tree, :root)
      expect(move_tree2.root.children).not_to be_empty
    end
  end

  describe '#each' do
    before do
      # Create a simple tree with 3 levels (including the root)
      3.times { |i| move_tree.root.add_child([i + 2, 1]) }
      move_tree.root.children.each { |node| node.add_child([2, 2]) }
    end

    it 'iterates through a tree in level order' do
      i = 0
      move_tree.each do |node|
        if i == 0 # Root node
          expect(node).to eq(move_tree.root)
        elsif i >= 4 # Leaf nodes
          expect(node).to eq(MoveTreeNode.new([2, 2]))
        else # Other nodes
          expected_node = MoveTreeNode.new([i + 1, 1])
          expected_node.add_child([2, 2])
          expect(node).to eq(expected_node)
        end
        i += 1
      end
    end

    it 'returns itself' do
      expect(move_tree.each {}).to be(move_tree)
    end
  end

  describe '#trim_branch!' do
    before do
      # Create a simple tree with 3 levels (including the root)
      3.times { |i| move_tree.root.add_child([i + 2, 1]) }
      move_tree.root.children[0].add_child([2, 2])
    end

    context 'when given a valid location within the tree' do
      it 'removes a single node from the tree' do
        expect(proc { move_tree.trim_branch!([3, 1]) }).to change(move_tree.root.children, :size).from(3).to(2)
      end

      it 'removes an entire branch (a node and its children)' do
        move_tree.trim_branch!([2, 1])
        expect(move_tree.to_a.include?([2, 2])).to be(false)
      end
  
    end

    context 'when given a valid node within the tree' do
      it 'removes a single node from the tree' do
        expect(proc { move_tree.trim_branch!(MoveTreeNode.new([3, 1])) }).to change(move_tree.root.children, :size).from(3).to(2)
      end

      it 'removes an entire branch (a node and its children)' do
        move_tree.trim_branch!(MoveTreeNode.new([2, 1]))
        expect(move_tree.to_a.include?([2, 2])).to be(false)
      end
    end

    context 'when given a location not belonging to a node within the tree' do
      it 'returns nil' do
        expect(move_tree.trim_branch!([2, 7])).to be(nil)
      end
    end

    context 'when given a node not within the tree' do
      it 'returns nil' do
        expect(move_tree.trim_branch!(MoveTreeNode.new([2, 7]))).to be(nil)
      end
    end
  end

  describe '#to_a' do
    before do
      # Create a simple tree with 3 levels (including the root)
      3.times { |i| move_tree.root.add_child([i + 2, 1]) }
      move_tree.root.children[0].add_child([2, 2])
    end

    it 'returns an array of locations in the tree in level order' do
      expect(move_tree.to_a).to eq([[2, 1], [3, 1], [4, 1], [2, 2]])
    end
  end
end

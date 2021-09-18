# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/move_tree_node'

RSpec.describe MoveTreeNode do
  let(:node) { described_class.new([0, 0]) }

  describe '#add_child' do
    context 'given an array of the location' do
      it 'adds a MoveTreeNode as a child' do
        expect(proc { node.add_child([1, 1]) }).to change(node.children, :size).from(0).to(1)
      end

      it 'correctly assigns array to loc of child node' do
        node.add_child([1, 1])
        expect(node.children[0].loc).to eq([1, 1])
      end

      it 'returns the children array' do
        expect(node.add_child([1, 1])).to eq([MoveTreeNode.new([1, 1])])
      end
    end

    context 'given a MoveTreeNode' do
      let(:child) { described_class.new([2, 2]) }
      before do
        child.add_child([1, 1])
      end
      it 'adds the MoveTreeNode as a child' do
        expect(proc { node.add_child(child) }).to change(node.children, :size).from(0).to(1)
      end

      it 'assigns the child node to be the node passed in' do
        node.add_child(child)
        expect(node.children[0]).to eq child
      end

      it 'returns the children array' do
        expect(node.add_child(child)).to eq([child])
      end
    end

    context 'given other types of objects' do
      it 'raises an ArgumentError' do
        error_message = 'Argument is a String; should be Array or MoveTreeNode'
        expect(proc { node.add_child('[1, 2]') }).to raise_error(proc { ArgumentError.new(error_message) })
      end
    end
  end

  describe '#remove_child' do
    before do
      node.add_child([1, 1])
      node.add_child([2, 2])
    end
    context 'given a location of a child node' do
      it 'removes the child' do
        expect(proc { node.remove_child([1, 1]) }).to change(node.children, :size).from(2).to(1)
        expect(node.children.include?(MoveTreeNode.new([1, 1]))).to be(false)
      end

      it 'returns a MoveTreeNode with given location' do
        expect(node.remove_child([1, 1])).to eq(MoveTreeNode.new([1, 1]))
      end
    end

    context 'given a location of none of the child nodes' do
      it 'returns nil' do
        expect(node.remove_child([1, 2])).to eq(nil)
      end
    end

    context 'given a MoveTreeNode object that is a child' do
      it 'removes the child node' do
        expect(proc { node.remove_child(MoveTreeNode.new([1, 1])) }).to change(node.children, :size).from(2).to(1)
        expect(node.children.include?(MoveTreeNode.new([1, 1]))).to be(false)
      end

      it 'returns the MoveTreeNode' do
        child = MoveTreeNode.new([1, 1])
        expect(node.remove_child(child)).to eq(child)
      end
    end

    context 'given a MoveTreeNode object that is not a child' do
      it 'returns nil' do
        expect(node.remove_child(MoveTreeNode.new([1, 2]))).to eq(nil)
      end
    end

    context 'given an object that is not an Array nor a MoveTreeNode' do
      it 'raises and ArgumentError' do
        error_message = 'Argument is a String; should be Array or MoveTreeNode'
        expect(proc { node.remove_child('[1, 1]') }).to raise_error(proc { ArgumentError.new(error_message) })
      end
    end
  end
end

# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/chess_piece'

RSpec.describe ChessPiece do
  subject(:abstract_piece) { described_class.new('piece', 'white', [0, 0], 0) }
  let(:overwrite_err) { StandardError.new('Overwrite for each piece') }

  describe '#to_s' do
    it 'outputs the string with name, color, and location' do
      expect(abstract_piece.to_s).to eq("\e[0;37;49mpiece \e[0m")
    end
  end

  describe '#<=>' do
    let(:fake_queen) { described_class.new('♛', 'white', [0, 0], 9) }
    let(:fake_queen2) { described_class.new('♕', 'black', [0, 0], 9) }
    let(:fake_bishop) { described_class.new('♝'.white, 'white', [0, 0], 3) }
    let(:fake_knight) { described_class.new('♘', 'black', [0, 0], 3) }
    context 'when piece values are different' do
      it 'returns -1 when other\'s points is greater' do
        comparison = fake_bishop <=> fake_queen
        expect(comparison).to be(-1)
        expect(fake_bishop < fake_queen).to be(true)
      end

      it 'returns 1 when other\'s points is less' do
        comparison = fake_queen <=> fake_bishop
        expect(comparison).to be(1)
        expect(fake_queen > fake_bishop).to be(true)
      end
    end

    context 'when piece values are the same' do
      it 'equates two equal pieces' do
        comparison = fake_queen <=> fake_queen2
        expect(comparison).to be(0)
        expect(fake_queen == fake_queen2).to be(true)
      end

      it 'returns 1 when LHS is a bishop and RHS is a knight' do
        comparison = fake_bishop <=> fake_knight
        expect(comparison).to be(1)
        expect(fake_bishop > fake_knight).to be(true)
      end

      it 'returns -1 when LHS is a knight and RHS is a bishop' do
        comparison = fake_knight <=> fake_bishop
        expect(comparison).to be(-1)
        expect(fake_knight < fake_bishop).to be(true)
      end
    end
  end

  describe '#build_directional_tree_nodes' do
    context 'when given vertical direction' do
      it 'returns positive 7 available spaces' do
        space_node = abstract_piece.build_directional_tree_nodes([1, 0])
        move_tree = MoveTree.new([0, 0])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |row| [row, 0] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end

      it 'returns negative 7 available spaces' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, 0])
        abstract_piece.instance_variable_set(:@position, [7, 7])
        move_tree = MoveTree.new([7, 7])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |row| [7 - row, 7] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end
    end

    context 'when given horizontal direction' do
      it 'returns positve 7 available spaces' do
        space_node = abstract_piece.build_directional_tree_nodes([0, 1])
        move_tree = MoveTree.new([0, 0])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |col| [0, col] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end

      it 'returns negative 7 available spaces' do
        space_node = abstract_piece.build_directional_tree_nodes([0, -1])
        abstract_piece.instance_variable_set(:@position, [7, 7])
        move_tree = MoveTree.new([7, 7])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |col| [7, 7 - col] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end
    end

    context 'when given positive right-diagonal direction' do
      it 'gives 7 diagonal spaces' do
        space_node = abstract_piece.build_directional_tree_nodes([1, 1])
        move_tree = MoveTree.new([0, 0])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |val| [val, val] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end

      it 'gives 0 spaces at [7, 7]' do
        space_node = abstract_piece.build_directional_tree_nodes([1, 1])
        abstract_piece.instance_variable_set(:@position, [7, 7])
        move_tree = MoveTree.new([7, 7])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = []
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end
    end

    context 'when given negative right-diagonal direction' do
      it 'gives 0 spaces at [0, 0]' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, -1])
        move_tree = MoveTree.new([0, 0])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = []
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end

      it 'gives 7 diagonal spaces at [7, 7]' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, -1])
        abstract_piece.instance_variable_set(:@position, [7, 7])
        move_tree = MoveTree.new([7, 7])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |val| [7 - val, 7 - val] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end
    end

    context 'when given positive left-diagonal direction' do
      it 'gives 7 diagonal spaces at [7, 0]' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, 1])
        move_tree = MoveTree.new([7, 0])
        abstract_piece.instance_variable_set(:@position, [7, 0])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = (1..7).map { |val| [7 - val, val] }
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end

      it 'gives 0 spaces at [0, 7]' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, -1])
        abstract_piece.instance_variable_set(:@position, [0, 7])
        move_tree = MoveTree.new([0, 7])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = []
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end
    end

    context 'when given negative left-diagonal direction' do
      it 'gives 0 spaces at [7, 0]' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, -1])
        move_tree = MoveTree.new([7, 0])
        abstract_piece.instance_variable_set(:@position, [7, 0])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = []
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end

      it 'gives 0 diagonal spaces at [0, 7]' do
        space_node = abstract_piece.build_directional_tree_nodes([-1, -1])
        abstract_piece.instance_variable_set(:@position, [0, 7])
        move_tree = MoveTree.new([0, 7])
        move_tree.root.add_child(space_node)
        abstract_piece.instance_variable_set(:@move_tree, move_tree)
        expected_output = []
        expect(abstract_piece.possible_moves.to_a).to eq(expected_output)
      end
    end
  end
end

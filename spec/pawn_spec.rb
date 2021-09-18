# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/pawn'

RSpec.describe Pawn do
  let(:white_pawn) { described_class.new('white', [1, 0]) }
  let(:black_pawn) { described_class.new('black', [6, 1]) }

  describe '#possible_moves' do
    context 'having not moved before' do
      it 'returns only valid moves for a white pawn' do
        expect(white_pawn.possible_moves.to_a).to eq([[2, 0], [2, 1], [3, 0]])
      end

      it 'returns only valid moves for a black pawn' do
        expect(black_pawn.possible_moves.to_a).to eq([[5, 1], [5, 2], [5, 0], [4, 1]])
      end
    end

    context 'having moved' do
      it 'returns only valid moves for a white pawn' do
        white_pawn.moved
        expect(white_pawn.possible_moves.to_a).to eq([[2, 0], [2, 1]])
      end

      it 'returns only valid moves for a black pawn' do
        black_pawn.moved
        expect(black_pawn.possible_moves.to_a).to eq([[5, 1], [5, 2], [5, 0]])
      end
    end
  end

  describe '#moved' do
    it 'flags white pawn as having moved' do
      expect(proc { white_pawn.moved }).to change(white_pawn, :has_moved).to(true)
    end
    it 'flags black pawn as having moved' do
      expect(proc { black_pawn.moved }).to change(black_pawn, :has_moved).to(true)
    end
  end

  describe '#can_capture?' do
    let(:pawn1) { described_class.new('white', [3, 3]) }
    let(:pawn2) { described_class.new('black', [4, 2]) }
    let(:pawn3) { described_class.new('black', [4, 3]) }

    context 'when a pawn can capture the piece' do
      it 'returns true for black pawn' do
        expect(pawn1.can_capture?(pawn2)).to be(true)
      end

      it 'returns true for white pawn' do
        expect(pawn2.can_capture?(pawn1)).to be(true)
      end
    end

    context 'when a pawn cannot capture the piece' do
      it 'returns false for white pawn' do
        expect(pawn1.can_capture?(pawn3)).to be(false)
      end

      it 'returns false for white pawn' do
        expect(pawn3.can_capture?(pawn1)).to be(false)
      end
    end
  end
end

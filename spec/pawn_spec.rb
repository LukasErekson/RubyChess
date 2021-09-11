# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/pawn'

RSpec.describe Pawn do
  let(:bpawn) { described_class.new('black', [1, 0]) }
  let(:wpawn) { described_class.new('white', [6, 1]) }

  describe '#legal_moves' do
    context 'having not moved before' do
      it 'returns only valid moves for a white pawn' do
        expect(bpawn.legal_moves).to eq([[2, 0], [2, 1], [3, 0]])
      end

      it 'returns only valid moves for a black pawn' do
        expect(wpawn.legal_moves).to eq([[5, 0], [5, 1], [5, 2], [4, 1]])
      end
    end

    context 'having moved' do
      it 'returns only valid moves for a white pawn' do
        bpawn.moved
        expect(bpawn.legal_moves).to eq([[2, 0], [2, 1]])
      end

      it 'returns only valid moves for a black pawn' do
        wpawn.moved
        expect(wpawn.legal_moves).to eq([[5, 0], [5, 1], [5, 2]])
      end
    end
  end

  describe '#moved' do
    it 'flags white pawn as having moved' do
      expect(proc { bpawn.moved }).to change(bpawn, :has_moved).to(true)
    end
    it 'flags black pawn as having moved' do
      expect(proc { wpawn.moved }).to change(wpawn, :has_moved).to(true)
    end
  end

  describe '#can_capture?' do
    let(:pawn1) { described_class.new('black', [3, 3]) }
    let(:pawn2) { described_class.new('white', [4, 2]) }
    let(:pawn3) { described_class.new('white', [4, 3]) }

    context 'when a pawn can capture the piece' do
      it 'returns true for black pawn' do
        expect(pawn1.can_capture?([4, 2], pawn2)).to be(true)
      end

      it 'returns true for white pawn' do
        expect(pawn2.can_capture?([3, 3], pawn1)).to be(true)
      end
    end

    context 'when a pawn cannot capture the piece' do
      it 'returns false for white pawn' do
        expect(pawn1.can_capture?([4, 3], pawn3)).to be(false)
      end

      it 'returns false for white pawn' do
        expect(pawn3.can_capture?([3, 3], pawn1)).to be(false)
      end
    end
  end
end

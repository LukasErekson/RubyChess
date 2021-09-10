# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/chess_piece'

RSpec.describe ChessPiece do
  subject(:abstract_piece) { described_class.new('piece', 'white', [0, 0], 0) }
  let(:overwrite_err) { StandardError.new('Overwrite for each piece') }
  describe '#legal_moves' do
    it 'raises an overwrite error' do
      expect(proc { abstract_piece.legal_moves }).to raise_error(proc { overwrite_err })
    end
  end

  describe '#can_capture?' do
    it 'raises an overwrite error' do
      expect(proc { abstract_piece.legal_moves }).to raise_error(proc { overwrite_err })
    end
  end

  describe '#to_s' do
    it 'outputs the string with name, color, and location' do
      expect(abstract_piece.to_s).to eq('white piece at [0, 0]')
    end
  end

  describe '#moves_in_bounds' do
    context 'given valid positions' do
      it 'returns the same positions' do
        expect(abstract_piece.moves_in_bounds([[0, 0], [1, 0], [5, 3]])).to eq([[0, 0], [1, 0], [5, 3]])
      end
    end

    context 'given invalid positions' do
      it 'returns an empty array' do
        expect(abstract_piece.moves_in_bounds([[8, 8], [-1, 2], [-8, -2], [0, 9]])).to eq([])
      end
    end

    context 'given a mix of valid and invalid positions' do
      it 'returns only the valid positions' do
        expect(abstract_piece.moves_in_bounds([[0, 1], [5, 8], [2, 4], [-1, 0]])).to eq([[0, 1], [2, 4]])
      end
    end
  end
end

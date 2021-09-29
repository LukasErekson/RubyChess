# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_pieces/chess_piece'

RSpec.describe ChessPiece do
  subject(:abstract_piece) { described_class.new('piece', 'white', [0, 0], 0) }
  let(:overwrite_err) { StandardError.new('Overwrite for each piece') }

  describe '#to_s' do
    it 'outputs the string with name, color, and location' do
      expect(abstract_piece.to_s).to eq('piece ')
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
end

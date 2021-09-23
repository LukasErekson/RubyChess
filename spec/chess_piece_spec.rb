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
end

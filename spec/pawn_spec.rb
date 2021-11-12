# frozen_string_literal: true

require 'rspec'
require 'stringio'
require_relative '../lib/chess_pieces/pawn'
require_relative '../lib/chess_pieces/queen'

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
        white_pawn.move([1, 0])
        expect(white_pawn.possible_moves.to_a).to eq([[2, 0], [2, 1]])
      end

      it 'returns only valid moves for a black pawn' do
        black_pawn.move([6, 1])
        expect(black_pawn.possible_moves.to_a).to eq([[5, 1], [5, 2], [5, 0]])
      end
    end
  end

  describe '#move' do
    context 'calls to #move' do
      it 'flag white pawn as having moved' do
        expect(proc { white_pawn.move([1, 1]) }).to change(white_pawn, :move_count).to(1)
        expect(white_pawn.first_move?).to be(true)
      end
      it 'flag black pawn as having moved' do
        expect(proc { black_pawn.move([1, 1]) }).to change(black_pawn, :move_count).to(1)
        expect(black_pawn.first_move?).to be(true)
      end
      it 'iterate Pawn::move_count after each move' do
        5.times do |index|
          white_pawn.move([1, 1])
          expect(white_pawn.move_count).to be(index + 1)
        end
        expect(white_pawn.first_move?).to be(false)
      end
    end

    context 'when a pawn moves to a back row' do
      before do
        $stdout = StringIO.new
      end
      after do
        $stdin = STDIN
        $stdout = STDOUT
      end

      it 'returns queen for white pawn' do
        $stdin = StringIO.new("1\n")
        expect(white_pawn.move([7, 1])).to eq(Queen.new('white', [7, 1]))
      end

      it 'returns queen for black pawn' do
        $stdin = StringIO.new("1\n")
        expect(black_pawn.move([0, 1])).to eq(Queen.new('black', [0, 1]))
      end

      it 'returns rook for black pawn' do
        $stdin = StringIO.new("R\n")
        expect(black_pawn.move([0, 1])).to eq(Rook.new('black', [0, 1]))
      end

      it 'returns bishop for black pawn' do
        $stdin = StringIO.new("BISHOP\n")
        expect(black_pawn.move([0, 1])).to eq(Bishop.new('black', [0, 1]))
      end

      it 'returns knight for black pawn' do
        $stdin = StringIO.new("K\n")
        expect(black_pawn.move([0, 1])).to eq(Knight.new('black', [0, 1]))
      end

      it 'rasies an error for an invalid option' do
        $stdin = StringIO.new("6\n2\n")
        expect(proc { black_pawn.move([0, 1]) }).not_to raise_error
      end
    end

    context 'when a computer player advances to the last space' do
      it 'returns a queen piece for promotion' do
        expect(black_pawn.send(:new_piece_type, 'computer')).to eq(Queen)
      end

      it 'returns a random piece for promotion' do
        types = [Queen, Knight, Rook, Bishop]
        expect(types.include?(black_pawn.send(:new_piece_type, 'random'))).to be(true)
      end
    end
  end

  describe '#can_capture?' do
    let(:pawn1) { described_class.new('white', [3, 3]) }
    let(:pawn2) { described_class.new('black', [4, 2]) }
    let(:pawn3) { described_class.new('black', [4, 3]) }

    context 'when a pawn can capture another pawn (standard)' do
      it 'returns true for black pawn' do
        expect(pawn1.can_capture?(pawn2)).to be(true)
      end

      it 'returns true for white pawn' do
        expect(pawn2.can_capture?(pawn1)).to be(true)
      end
    end

    context 'when a pawn cannot capture another pawn (standard)' do
      it 'returns false for white pawn' do
        expect(pawn1.can_capture?(pawn3)).to be(false)
      end

      it 'returns false for white pawn' do
        expect(pawn3.can_capture?(pawn1)).to be(false)
      end
    end

    context 'when En Passant applies' do
      it 'returns true for white pawn' do
        pawn1.move([4, 3])
        pawn2.move([4, 4])
        expect(pawn1.can_capture?(pawn2)).to be(true)
      end
      it 'returns true for black pawn' do
        pawn2.move([3, 3])
        pawn1.move([3, 4])
        expect(pawn2.can_capture?(pawn1)).to be(true)
      end
    end

    context 'when En Passant does not apply' do
      it 'returns false for white pawn' do
        pawn1.move([4, 3])
        pawn2.move([5, 4])
        pawn2.move([4, 4])
        expect(pawn1.can_capture?(pawn2)).to be(false)
      end

      it 'returns false for black pawn' do
        pawn2.move([3, 3])
        pawn1.move([2, 4])
        pawn1.move([3, 4])
        expect(pawn2.can_capture?(pawn1)).to be(false)
      end
    end
  end
end

# frozen_string_literal: true

require 'rspec'
require_relative '../lib/chess_game'

# Require all the chess pieces
Dir.children('./lib/chess_pieces').each { |piece_file| require_relative "../lib/chess_pieces/#{piece_file}" }

##
# Creates an empty board so that the tests can set up any configuration
# of ChessGame::@board
def blank_board
  rows = []
  8.times do
    blank_rows = []
    8.times { blank_rows << ChessGame::BLANK_SQUARE }
    rows << blank_rows
  end

  rows
end

RSpec.describe 'ChessGame#move' do
  let(:game) { ChessGame.new }
  let(:board) { game.instance_variable_get(:@board) }
  describe 'first turn' do
    context 'when a white pawn moves' do
      it 'lets pawn move forward one' do
        8.times do |col|
          expect(proc {
                   game.move([1, col], [2, col]); game.instance_variable_set(:@current_player_color, 'white')
                 }).to change {
                         board[1][col]
                       }.to('  ')
        end
      end

      it 'lets pawn move forward two' do
        8.times do |col|
          expect(proc {
                   game.move([1, col], [3, col]); game.instance_variable_set(:@current_player_color, 'white')
                 }).to change {
                         board[1][col]
                       }.to('  ')
        end
      end
    end

    context 'when a white knight moves' do
      it 'lets knight move to valid space' do
        expect(proc {
                 game.move([0, 1], [2, 0]); game.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       board[0][1]
                     }.to('  ')
        expect(proc {
                 game.move([0, 6], [2, 5]); game.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       board[0][6]
                     }.to('  ')
        expect(proc {
                 game.move([2, 0], [0, 1]); game.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       board[2][0]
                     }.to('  ')
        expect(proc {
                 game.move([2, 5], [0, 6]); game.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       board[2][5]
                     }.to('  ')
        expect(proc {
                 game.move([0, 1], [2, 2]); game.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       board[0][1]
                     }.to('  ')
        expect(proc {
                 game.move([0, 6], [2, 7]); game.instance_variable_set(:@current_player_color, 'white')
               }).to change {
                       board[0][6]
                     }.to('  ')
      end
    end

    context 'when black pawn moves' do
      it 'raises InvalidMoveError' do
        expect(proc { game.move([6, 0], [5, 0]) }).to raise_error(InvalidMoveError)
      end
    end
  end
end

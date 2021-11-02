# frozen_string_literal: true

require_relative './chess_game'
require 'yaml'

def main
  loop do
    puts <<~MAIN_MENU
      Welcome to RubyChess! Please select one of the following options:

      1. Start a new game of Human vs. Human
      2. Load a previously saved game
      3. Exit or quit
    MAIN_MENU

    player_input = gets.chomp
    player_input&.downcase

    case player_input&.to_i
    when 1
      game = ChessGame.new
      winner = game.play
      puts "#{winner} wins! Play again?" unless winner.nil? || winner == 'Stalemate'
      puts 'Looks like it\'s a stalemate! Play again?' if winner == 'Stalemate'
      next
    when 2
      'Load saved game'
      game_file = File.new(load_game, 'r')
      game = YAML.safe_load(game_file)
      game_file.close
      winner = game.play
      puts "#{winner} wins! Play again?" unless winner.nil?
      next
    else
      'Thank you! Have a nice day.'
      break
    end
  end
end

##
# Displays the saved games and allows a player to choose a saved file.
#
# @return [String] The string to the save file to load.
def load_game
  begin
    display_saves
    choice = gets.chomp
    raise StandardError, 'Please choose an option from the above list.' unless choice.to_i.between?(0,
                                                                                                    Dir.children('./saves').size - 1)
  rescue StandardError => e
    puts e.message
    retry
  end

  "./saves/#{Dir.children('./saves')[choice.to_i]}"
end

##
# Displays the saved games for the player to choose from.
def display_saves
  Dir.children('./saves').each_with_index { |name, idx| puts "#{idx}. #{name}" }
end

main

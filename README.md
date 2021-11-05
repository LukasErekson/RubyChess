# RubyChess
A Ruby implementation of Chess to be played in the terminal.

## Table of Contents
1. [Features](#features)
2. [Requirements](#requirements)
3. [Installing & Playing](#installing-and-playing)
    - [Gameplay](#gameplay)
4. [Developing & Contributing](#developing-and-contributing)
    - [Testing](#testing)
    - [Contributing](#contributing)
5. [Purpose](#purpose)

## Features
This implementation features all the standard rules of chess, including some things such as castling the king, the situational move En Passant, and pawn promotion to a player's choice of pieces. It also allows players to quit a game early, saving the state of the board and turn history in the `saves` folder as a YAML file.

## Requirements
Ruby 2.7+ is required. The gem `colorize` also needs to be installed in order for the board and chess pieces to render correctly.

## Installing and Playing
To install and play, simply clone the main branch with

`git clone https://github.com/LukasErekson/RubyChess.git`

Then, run `ruby lib/main.rb` in the downloaded `RubyChess` directory. A game menu will appear giving you options to start the game, load a saved game, or quit.

### Gameplay
At any point during the game, typing `help` or `tutorial` will provide detailed instructions on how to make moves (and if you're in check, it will provide a list of moves that you can take to get out of check).

The basic gist of the gameplay consits of typing in the location of the piece you would like to move and then typing the locaiton where you would like it to go. The following syntax is accepted to move a piece from a2 to a4:
- `a2a4`
- `a2 to a4`

To exit the game early, type `quit`, and you will be prompted to give a name for the save file before the program exits to the main menu.

## Developing and Contributing
### Testing
A custom test suite with over 100 tests written with RSpec tests the major functionality of the game pieces and the board. It can serve as a good benchmark for anyone who wishes to contribute to the repository while maintaining stability. I also used SimpleCov as one measure of completeness to make sure niche cases were reached and behave as expected.

### Contributing
Feel free to fork this repo and build on it in any way! I welcome any pull requests that aim to improve the quality of the project. As a matter of fact, it would give me some more experience reviewing others' code and going through pull requests.

## Purpose
This serves as a capstone project for [The Odin Project's Ruby Programming course](https://www.theodinproject.com/paths/full-stack-ruby-on-rails/courses/ruby-programming). The whole repository is also an opportunity to practice the standards of a git repository and trying out a new workflow. Although this project is done on my own, I hope that the way I use git provides me with good practice at developing software in team-friendly way.
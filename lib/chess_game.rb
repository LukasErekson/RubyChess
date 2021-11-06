# frozen_string_literal: true

require 'colorize'
require 'stringio'
require 'yaml'
require_relative 'chess_pieces/pawn'
require_relative 'chess_pieces/rook'
require_relative 'chess_pieces/knight'
require_relative 'chess_pieces/bishop'
require_relative 'chess_pieces/queen'
require_relative 'chess_pieces/king'
require_relative 'invalid_move_error'

##
# A chess game that contains the game board, rules,
# validation of moves, and computing check/checkmate.
class ChessGame
  WHITE_SQUARE = { background: :light_red }.freeze
  BLACK_SQAURE = { background: :red }.freeze
  BLANK_SQUARE = '  '
  BOARD_TO_COORDINATES = { 'a' => 0, 'b' => 1, 'c' => 2, 'd' => 3,
                           'e' => 4, 'f' => 5, 'g' => 6, 'h' => 7 }.freeze
  COORDINATES_TO_BOARD = BOARD_TO_COORDINATES.each_with_object({}) { |pair, obj| obj[pair[1]] = pair[0] }.freeze

  ##
  # Creates instance variables and sets up the board for
  # the start of the game.
  def initialize(white_player='human', black_player='human')
    @board = setup_board
    @current_player_color = 'white'
    @king_locs = { white: [0, 4], black: [7, 4] }
    @move_history = []
    @game_winner = nil
    @check_in_play = false
    @castle_king = false
    @players = { 'white' => white_player, 'black' => black_player }
  end

  ##
  # Runs the main game loop for a chess game, which is comprised
  # of several stages:
  # 1. Parse player input
  # 2. Attempt to make a move
  # 3. Check for check/checkmate
  # 4. Repeat until game over or saved
  #
  # @return [String] @game_winner The winner of the game if there is one.
  def play
    puts self
    while @game_winner.nil?
      puts "It's #{@current_player_color}'s turn."

      case @players[@current_player_color]
      when 'human'
        input_command = player_input
      when 'random'
        input_command = random_move
      else
        input_command = random_move
      end

      if input_command.nil?
        puts 'Please input a legal move. Type "help" for an example.'
        next
      elsif input_command == 'save'
        break
      end

      case input_command.size
      when 2
        from, to = input_command
      end

      begin
        make_move(from, to)
        @move_history << "#{convert_algebraic_coordinates(from)}#{convert_algebraic_coordinates(to)}"
        puts self
      rescue InvalidMoveError => e
        puts 'Invalid move!'
        puts e.message
        next
      rescue StandardError => e
        puts e.message
      end

      # Check whether the game is over or not
      case check_game_over
      when 'Checkmate'
        @game_winner = @current_player_color == 'white' ? 'black' : 'white'
        puts 'Checkmate!'
      when 'Stalemate'
        @game_winner = 'Stalemate'
        puts 'It\'s a draw!'
      else
        @game_winner = nil
      end
    end

    @game_winner
  end

  ##
  # Accepts player input and either returns the components needed to input a
  # move or saves the game.
  #
  # @return [Array<Array<Integer>>] An array of arrays of length 2 representing
  #                                 +from+ and +to+ to pass into #make_move.
  def player_input
    input = gets.chomp
    input = input&.downcase
    case player_input_type(input)
    when 'move'
      parse_move(input)
    when 'help'
      print_help_menu
    when 'save'
      save_game
    end
  end

  ##
  # Parses a move input string to determine the type of input given. The
  # different suppored moves are:
  # 1. A string of length 4 indicating the start space and the end space.
  # - e.g 'a2a4' would return [[0, 1], [0, 3]]
  # 2. A string of length 8 in the form of "[start] to [end]"
  # - e.g 'a2 to a4' would return [[0, 1], [0, 3]]
  # TODO : Add more supported moves
  #
  # @param [String] input The raw player input
  #
  # @return [Array<Array<Integer>>] An array of arrays of length 2 representing
  #                                 +from+ and +to+ to pass into #make_move.
  def parse_move(input)
    case input.size
    when 4
      from = convert_coordinates(input[0..1])
      to = convert_coordinates(input[2..3])
      [from, to]
    when 8
      from = convert_coordinates(input[0..1])
      to = convert_coordinates(input[-2..-1])
      [from, to]
    end
  end

  ##
  # Converts algebraic notation space names to coordinates corresponding with
  # @board.
  #
  # @param [String] coord_str A string of length 2 that has encoded within it
  #                           the column and row of a space on the chess board.
  # @return [Array<Integer>] An array of integers of length 2 denoting the row
  #                          and column positions corresponding to @board.
  #
  # For example, passing in 'a4' would return [0, 3].
  def convert_coordinates(coord_str)
    [(coord_str[1].to_i - 1), BOARD_TO_COORDINATES[coord_str[0]]]
  end

  ##
  # Converts coordinates into algebraic notation space names. Inverse method
  # of +convert_coordinates+.
  #
  # @param [Array<Integer>] coord_arr An array of integers of length 2
  #                                   corresponding to the row and column of
  #                                   the space on +@board+.
  #
  # @return [String] The string corresponding to the row and column name of the
  #                  space of the board using algebraic notation.
  def convert_algebraic_coordinates(coord_arr)
    "#{COORDINATES_TO_BOARD[coord_arr[1]]}#{coord_arr[0] + 1}"
  end

  ##
  # Returns the type of player input, whether they input a game-ending command
  # or a move command.
  #
  # @param [String] input String of the player input to parse and determine the
  #                       type of input.
  # @return [String] The type of player input; 'save', 'help', or 'move'.
  def player_input_type(input)
    %w[save quit exit end].each { |end_word| return 'save' if input.include?(end_word) }

    %w[help tutorial ?].each { |help_word| return 'help' if input.include?(help_word) }

    'move'
  end

  ##
  # Saves the game by dumping the object into a YAML file.
  def save_game
    puts 'Please input a name for the save file.'
    file_name = gets.chomp
    while File.exist?("saves/#{file_name}")
      puts "saves/#{file_name} already exists; please choose a different name."
      file_name = gets.chomp
    end
    save_file = File.new("saves/#{file_name}", 'w')
    save_file.write(YAML.dump(self))
    save_file.close

    'save'
  end

  ##
  #  Prints the help menu complete with tutorial and move explanations
  #
  # @return [String] 'help_menu' after printing the help menu.
  def print_help_menu
    puts <<~HELP_MENU
      To move a piece, type the two character location of the piece and then the
      two character location of where you want it to move. For example, if you
      want to move the pawn at a2 forward two spaces, type "a2a4" or "a2 to a4".

      To save the game, type 'save', 'exit', or 'quit', and you will be prompted
      to name the save file.

      To get this menu back, simply type 'help', 'tutorial' or '?'.
    HELP_MENU

    print_out_of_check_moves if @check_in_play

    'help_menu'
  end

  ##
  # Prints the moves that the current player can make to get out of check.
  def print_out_of_check_moves
    puts 'Here are potential moves to get out of of check:'
    available_moves.each do |from_loc, to_loc_array|
      puts "#{convert_algebraic_coordinates(from_loc)} => #{to_loc_array.map do |to|
                                                              convert_algebraic_coordinates(to)
                                                            end }"
    end
  end

  ##
  # Moves a piece at a given location to another location if
  # the move is valid. Raises an InvalidMoveError otherwise.
  #
  # @param [Array<Integer>] from  An integer array of length 2 denoting the
  #                               position of the piece to move.
  # @param [Array<Integer>] to    An integer array of length 2 denoting the
  #                               position to move the piece at +from+ to.
  def make_move(from, to)
    # Raises an execption if the move isn't valid
    validate_move(from, to)

    frow, fcol = from
    piece = @board[frow][fcol]
    trow, tcol = to
    other_space = @board[trow][tcol]

    # Keep track of move_counts for Pawns and Kings
    case piece
    when King
      reset_move_count = piece.moved?
    when Pawn
      reset_move_count = piece.move_count
    end

    # Capture a piece if the pawn performed En Passant
    @board[frow][tcol] = BLANK_SQUARE if piece.is_a?(Pawn) && get_en_passant_moves(piece).include?(to)

    # Move the piece on the board
    if piece.is_a?(Pawn)
      @board[trow][tcol] = piece.move(to, @players[@current_player_color])
    else
      @board[trow][tcol] = piece.move(to)
    end
    
    @board[frow][fcol] = BLANK_SQUARE

    # If a piece is a king, do special checks
    if piece.is_a?(King)
      @king_locs[@current_player_color.to_sym] = to

      # Check if the king is being castled
      if @castle_king
        # Reset the flag for the other player's king
        @castle_king = false
        if tcol == fcol - 2
          @board[trow][tcol + 1] = @board[trow][0].move([trow, tcol + 1])
          @board[trow][0] = BLANK_SQUARE
        else
          @board[trow][tcol - 1] = @board[trow][7].move([trow, tcol - 1])
          @board[trow][7] = BLANK_SQUARE
        end
      end
    end

    # Check for check
    check_piece = check_check

    @check_in_play = !check_check.nil?

    unless check_piece.nil?

      # Move keeps/makes their own king in check.
      if check_piece.color != @current_player_color || check_piece.is_a?(King)
        # Undo the move
        @board[frow][fcol] = piece.move(from)
        @board[trow][tcol] = other_space
        # Undo movement for tracking ones
        case piece
        when King
          piece.moved = reset_move_count
        when Pawn
          piece.move_count -= 2
        end
        raise(InvalidMoveError, "Moving that #{piece.class} leaves your king in check!")
      else
        puts 'Check!'
        puts 'Type "help" to get a list of moves to get out of check!'
      end
    end

    # Change whose turn it is
    change_turn
  end

  ##
  # Determines whether or not the move is a valid move. If the move is valid,
  # it returns that space on the board.
  # Raises an InvalidMoveError with a specific message if the move is invalid.
  #
  # @param [Array<Integer>] from  An integer array of length 2 denoting the
  #                               position of the piece to move.
  # @param [Array<Integer>] to    An integer array of length 2 denoting the
  #                               position to move the piece at +from+ to.
  def validate_move(from, to)
    frow, fcol = from
    piece = @board[frow][fcol]
    raise(InvalidMoveError, "No piece at #{convert_algebraic_coordinates(from)}") unless piece.is_a? ChessPiece

    unless piece.color == @current_player_color
      raise(InvalidMoveError,
            "You cannot move opponent's piece at #{convert_algebraic_coordinates(from)}")
    end

    possible_moves = legal_moves(piece)
    unless possible_moves.include?(to)
      # Check if it's trying to castle the king
      if piece.is_a?(King) && !piece.moved? && can_castle?(from, to)
        @castle_king = true
      else
        raise(InvalidMoveError,
              "Your #{piece.class} cannot move from #{convert_algebraic_coordinates(from)} to #{convert_algebraic_coordinates(to)}.")
      end
    end

    trow, tcol = to
    @board[trow][tcol]
  end

  ##
  # Returns whether or not a king can make the castle move or not
  #
  # @param [Array<Integer>] from  An integer array of length 2 denoting the
  #                               position of the piece to move.
  # @param [Array<Integer>] to    An integer array of length 2 denoting the
  #                               position to move the piece at +from+ to.
  # @return [Boolean] whether the king can make the castle move or not.
  def can_castle?(from, to)
    return false unless from[0] == to[0] && to[1].between?(from[1] - 2, from[1] + 2)

    tcol = to[1]
    fcol = from[1]
    row = from[0]
    case fcol - tcol
    when 2 # Moving left, check all the left spaces are empty
      @board[row][0].is_a?(Rook) && @board[row][1] == BLANK_SQUARE && @board[row][2] == BLANK_SQUARE && @board[row][3] == BLANK_SQUARE
    when -2 # Moving right
      @board[row][7].is_a?(Rook) && @board[row][6] == BLANK_SQUARE && @board[row][5] == BLANK_SQUARE
    else
      false
    end
  end

  ##
  # Determines whether the game ends with a checkmate or stalemate.
  #
  # @return [String] "Checkmate" for a game over, "Stalemate" for a draw, and
  #                  "continue" otherwise.
  def check_game_over
    immovable = available_moves.nil?
    # Checkmate condition
    return 'Checkmate' if @check_in_play && immovable

    # Stalemate condition
    return 'Stalemate' if !@check_in_play && immovable

    # Neither conidtions met
    'continue'
  end

  ##
  # Returns an array of the legal moves that the piece can make.
  # This will prevent pieces from going through other pieces (except for the
  # knight, of course). It does so by iterating through +chess_piece+'s move
  # tree in level order, dequeing any nodes that are invalid.
  #
  # @param [ChessPiece] chess_piece The ChessPiece to find the legal moves of.
  # @return [Array<Array<Integer>>] Array of legal move spaces that the piece
  #                                  can move to.
  def legal_moves(chess_piece)
    return pawn_legal_moves(chess_piece) if chess_piece.is_a? Pawn

    move_tree = chess_piece.possible_moves
    legal_moves_array = []
    visit_queue = move_tree.root.children
    until visit_queue.empty?
      current_node = visit_queue.shift
      row, col = current_node.loc
      space = @board[row][col]
      # If it's a chess piece, check if it can capture.
      if space.is_a? ChessPiece
        # If the piece can capture it, add it as a valid space, but don't
        # add any of its children to visit_queue.
        next unless chess_piece.can_capture?(space)
      else
        # If there's not piece, it can continue along the move tree.
        current_node.children.each { |child| visit_queue << child }
      end
      # Append legal move locations
      legal_moves_array << current_node.loc
    end
    legal_moves_array
  end

  ##
  # Returns an array of legal moves that a pawn can make. Since a pawn can only
  # move diagonally if it can capture a piece, it is its own special case.
  #
  # @param [Pawn] pawn The pawn to find the legal moves of.
  # @return [Array<Array<Integer>>] Array of legal move spaces that the pawn
  #                                  can move to.
  def pawn_legal_moves(pawn)
    # Assign the move tree for pawn
    pawn.possible_moves
    # Check if pawn can capture right diagonal piece
    r_diag = pawn.move_tree.root.children[1]
    l_diag = pawn.move_tree.root.children[2]

    unless r_diag.nil?
      r_diag_loc = r_diag.loc
      r_diag_piece = @board[r_diag_loc[0]][r_diag_loc[1]]
      pawn.move_tree.trim_branch!(r_diag_loc) unless pawn.can_capture?(r_diag_piece)
    end

    unless l_diag.nil?
      # Check if pawn can capture left diagonal piece
      l_diag_loc = l_diag.loc
      l_diag_piece = @board[l_diag_loc[0]][l_diag_loc[1]]
      pawn.move_tree.trim_branch!(l_diag_loc) unless pawn.can_capture?(l_diag_piece)
    end

    # Check if the two spaces ahead of an unmoved pawn is occupied
    unless pawn.move_tree.root.children[0].children.empty?
      front_loc = pawn.move_tree.root.children[0].children[0].loc
      front_piece = @board[front_loc[0]][front_loc[1]]
      pawn.move_tree.trim_branch!(front_loc) if front_piece.is_a? ChessPiece
    end

    # Check if there is a piece immediately in front of the pawn
    front_loc = pawn.move_tree.root.children[0].loc
    front_piece = @board[front_loc[0]][front_loc[1]]
    pawn.move_tree.trim_branch!(front_loc) if front_piece.is_a? ChessPiece

    pawn.move_tree.to_a + get_en_passant_moves(pawn)
  end

  ##
  # Returns an array of the valid En Passant moves for a given pawn
  #
  # @param [Pawn] pawn The pawn to find the En Passant moves of.
  # @return [Array<Array<Integer>>] Array of legal move spaces that the pawn
  #                                  can move to where En Passant applies.
  def get_en_passant_moves(pawn)
    # Check spaces beside the pawn for En Passant
    pawn_row, pawn_col = pawn.position
    r_piece_loc = [pawn_row + pawn.direction, pawn_col + 1]
    r_piece = @board[pawn_row][pawn_col + 1]

    l_piece_loc = [pawn_row + pawn.direction, pawn_col - 1]
    l_piece = @board[pawn_row][pawn_col - 1]
    en_passant_moves = []

    en_passant_moves << r_piece_loc if (r_piece.is_a? Pawn) && pawn.can_capture?(r_piece)

    en_passant_moves << l_piece_loc if (l_piece.is_a? Pawn) && pawn.can_capture?(l_piece)

    en_passant_moves
  end

  ##
  # Checks whether a king is currently in check. If it is, it returns the piece
  # that puts it in check and nil otherwise.
  #
  # @return [ChessPiece or nil] The piece that puts a king in check and
  #                             nil otherwise.
  def check_check
    white_pieces, black_pieces = board_pieces_by_color
    # If black king is in check
    white_pieces.each do |piece|
      return piece if legal_moves(piece).include? @king_locs[:black]
    end
    # If white king is in check
    black_pieces.each do |piece|
      return piece if legal_moves(piece).include? @king_locs[:white]
    end

    nil
  end

  ##
  # Returns an hash of moves that will allow the current player to be out of
  # check. If the list is empty, nil is returned instead.
  #
  # @return [Hash <Array, Array> or nil] Array of valid moves unless it's empty.
  def available_moves
    player_pieces = board_pieces_by_color[@current_player_color == 'white' ? 0 : 1]
    valid_moves = {}
    player_pieces.each do |piece|
      valid_moves[piece.position] = []
      legal_moves(piece).each do |move|
        valid_moves[piece.position] << forecast_move(piece.position, move)
      rescue StandardError
        next
      end
    end

    valid_moves.filter! { |_key, val| !val.empty? }

    valid_moves.empty? ? nil : valid_moves
  end

  ##
  # Chooses a random move from the list of available moves.
  #
  # @return [Array<Array<Integer>>] [from, to]
  def random_move
    move_hash = available_moves
    from = move_hash.keys.sample
    to = move_hash[from].sample
    [from, to]
  end

  ##
  # Returns an array with 2 arrays, the first of which is all the white pieces
  # and the second is all the black pieces.
  #
  # @return [Array<Array<ChessPieces>>] Array of arrays for white and black
  #                                     pieces.
  def board_pieces_by_color
    pieces = @board.flatten.filter { |space| space.is_a? ChessPiece }
    white_pieces = pieces.filter { |piece| piece.color == 'white' }
    black_pieces = pieces.filter { |piece| piece.color == 'black' }
    [white_pieces, black_pieces]
  end

  ##
  # Returns a string of a board with pieces and appropriately
  # shaded spaces.
  #
  # @return [String] The chess board.
  def to_s
    string_stream = StringIO.new
    history_offset = @move_history.size
    8.downto(1) do |row|
      string_stream << " #{row} "
      @board[row - 1].each_with_index do |col, col_num|
        bg_color = (row - 1) % 2 == col_num % 2 ? BLACK_SQAURE : WHITE_SQUARE
        string_stream << col.to_s.colorize(bg_color)
      end
      string_stream << "\t"
      move_index = 8 - row + (history_offset - 8)
      move_index = 8 - row if (history_offset - 8).negative?
      string_stream << "#{move_index + 1}. #{@move_history[move_index]}"
      string_stream << "\n"
    end

    string_stream << '   a b c d e f g h '

    string_stream.string
  end

  protected

  ##
  # Returns an array that sets the board up for the
  # start of the game.
  #
  # @return [Array<Array>] The chess board represented as an array.
  def setup_board
    rows = place_pieces('white')
    rows += Array.new(4) { Array.new(8, BLANK_SQUARE) }
    rows += place_pieces('black')

    rows
  end

  ##
  # Returns the 2 arrays of the chess pieces in the proper places based od
  # their color.
  #
  # @param [String] color A string denoting the color of pieces to place.
  # @return [Array<Array<ChessPiece>>] The two rows of chess pieces for the
  #                                    standard setup of the chess board.
  def place_pieces(color)
    pawns = place_pawns(color)
    back_row_pieces = place_back_row(color)
    if color == 'white'
      [back_row_pieces, pawns]
    else
      [pawns, back_row_pieces]
    end
  end

  ##
  # Returns an array of pawns of the appropriate color on the
  # appropriate row based on +color+.
  #
  # @param [String] color A string denoting the color of pawns to place.
  # @return [Array<Pawn>] Row of pawns to place on the board.
  def place_pawns(color)
    pawn_row = color == 'white' ? 1 : 6
    pawns = []
    8.times { |col| pawns << Pawn.new(color, [pawn_row, col]) }
    pawns
  end

  ##
  # Returns an array of back row pieces of the appropriate color
  # on the appropriate row based on +color+.
  #
  # @param [String] color A string denoting the color of pieces to place.
  # @return [Array<ChessPiece>] The row of chess pieces in the standard setup.
  def place_back_row(color)
    back_row = color == 'white' ? 0 : 7
    [Rook.new(color, [back_row, 0]),
     Knight.new(color, [back_row, 1]),
     Bishop.new(color, [back_row, 2]),
     Queen.new(color, [back_row, 3]),
     King.new(color, [back_row, 4]),
     Bishop.new(color, [back_row, 5]),
     Knight.new(color, [back_row, 6]),
     Rook.new(color, [back_row, 7])]
  end

  ##
  # Changes whose turn it is by switching between 'black' and 'white'.
  #
  # @return [String] @current_player_color The current player color whose turn
  #                                        it is.
  def change_turn
    @current_player_color = @current_player_color == 'white' ? 'black' : 'white'
  end

  ##
  # Moves a piece at a given location to another location, checks if the the
  # move leaves the current player's king in check, returns the piece to its
  # original spot, and returns the move if valid.
  #
  # @param [Array<Integer>] from  An integer array of length 2 denoting the
  #                               position of the piece to move.
  # @param [Array<Integer>] to    An integer array of length 2 denoting the
  #                               position to move the piece at +from+ to.
  def forecast_move(from, to)
    # Raises an execption if the move isn't valid
    validate_move(from, to)

    frow, fcol = from
    piece = @board[frow][fcol]
    trow, tcol = to
    other_space = @board[trow][tcol]

    # Keep track of move_counts for Kings
    has_moved = piece.moved? if piece.is_a?(King)

    # Move the piece on the board
    if piece.is_a?(Pawn)
      @board[trow][tcol] = piece.move(to, @players[@current_player_color])
    else
      @board[trow][tcol] = piece.move(to)
    end
    @board[frow][fcol] = BLANK_SQUARE

    @king_locs[@current_player_color.to_sym] = to if piece.is_a?(King)

    # Check for check
    check_piece = check_check

    # Undo the move
    @king_locs[@current_player_color.to_sym] = from if piece.is_a?(King)
    @board[frow][fcol] = piece.move(from)
    @board[trow][tcol] = other_space

    # Undo movement for tracking ones
    case piece
    when King
      piece.moved = has_moved
    when Pawn
      piece.move_count -= 2
    end

    unless check_piece.nil? || (check_piece.color == @current_player_color && !check_piece.is_a?(King))
      # If check_piece is a King, then both kings are in check and it's an illegal
      # move.
      raise(InvalidMoveError, "Moving that #{piece.class} leaves your king in check!")
    end

    to
  end
end

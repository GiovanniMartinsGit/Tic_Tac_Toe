class Game
  BOARD_SIZE = 9
  WINNING_LINES = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6]
  ].freeze
  VALID_MODES = { '1' => 'Multiplayer', '2' => 'Solo', '3' => 'Watch' }.freeze
  VALID_LEVELS = { '1' => 'Easy', '2' => 'Hard' }.freeze
  COMPUTER_MARKERS = { '1' => 'X', '2' => 'O' }.freeze

  def initialize
    @board = (1..BOARD_SIZE).to_a
    @current_player = 1
  end

  def start_game
    puts 'Welcome to Tic Tac Toe!'
    game_mode = choose_game_mode
    if game_mode == '1'
      puts 'Let\'s start the game in Multiplayer mode!'
    elsif game_mode == '2'
      choose_difficulty_level(game_mode)
      puts 'Let\'s start the game in Solo mode against the computer!'
    elsif game_mode == '3'
      puts 'Let\'s watch the computer play against itself!'
      @current_player = [1, 2].sample
    end
    print_board
    until game_over? || tie?
      if game_mode == '1'
        player_move
      elsif game_mode == '2'
        make_move
      elsif game_mode == '3'
        computer_move
      end
      print_board
      @current_player = @current_player == 1 ? 2 : 1
    end
    puts game_over? ? "Player #{winner} won the game!" : 'It\'s a tie!'
    play_again?
  end
  
  private
  
  def choose_game_mode
    loop do
      puts 'Enter 1 to play Multiplayer, 2 to play Solo against the computer, or 3 to watch the computer play against itself:'
      input = gets.chomp
      if VALID_MODES.key?(input)
        puts "Let's start the game in #{VALID_MODES[input]} mode!"
        return input
      end
      puts 'Invalid choice, please try again.'
    end
  end
  
  def choose_difficulty_level(game_mode)
    if game_mode == '2'
      loop do
        puts 'Choose difficulty level:'
        VALID_LEVELS.each { |key, value| puts "#{key}. #{value}" }
        input = gets.chomp
        if VALID_LEVELS.key?(input)
          puts "You will play against the computer with #{VALID_LEVELS[input]} level difficulty."
          @computer_marker = COMPUTER_MARKERS[input]
          if input == '1'
            @computer_move_method = method(:computer_move_easy)
          elsif input == '2'
            @computer_move_method = method(:computer_move)
          end
          @current_player = @computer_move_method == method(:computer_move) ? 2 : 1
          return
        end
        puts 'Invalid choice, please try again.'
      end
    end
  end
  
  def make_move
    if @current_player == 1
      player_move
      if @difficulty_level == 'hard' # Verifica se o nível de dificuldade é "hard"
        @current_player = 2 # Troca para o jogador "O" (computador)
      end
    else
      @computer_move_method.call
      if @difficulty_level == 'hard' # Verifica se o nível de dificuldade é "hard"
        @current_player = 1 # Troca para o jogador "X" (usuário)
      end
    end
  end

  def print_board
    puts ''
    (0..BOARD_SIZE - 1).each_slice(3) do |row|
      puts row.map { |position| @board[position] }.join(' | ')
      puts '--+---+--' unless row == [6, 7, 8]
    end
    puts ''
  end

  def player_move
    marker = current_player_marker
    player_num = @current_player == 1 ? '1' : '2'
    position = nil
    loop do
      puts "Player #{player_num}, enter a number (1-9) to place your #{marker}:"
      position = gets.chomp.to_i - 1
      if valid_move?(position)
        @board[position] = marker
        break
      end
      puts 'Invalid move, please try again.'
    end
  end

  def computer_move
    marker = current_player_marker
    position = best_move(marker)
    @board[position] = marker
  end

  def computer_move_easy
    marker = current_player_marker
    position = random_move
    @board[position] = marker
  end

  def valid_move?(position)
    @board[position].is_a?(Integer) && position.between?(0, BOARD_SIZE - 1)
  end

  def current_player_marker
    @current_player == 1 ? 'X' : 'O'
  end

  def tie?
    @board.all? { |position| position.is_a?(String) }
  end

  def winner
    WINNING_LINES.each do |line|
      markers = [@board[line[0]], @board[line[1]], @board[line[2]]]
      return markers[0] if markers.uniq.size == 1 && !markers.include?(BOARD_SIZE + 1)
    end
    nil
  end

  def game_over?
    !winner.nil?
  end

  def best_move(marker)
    WINNING_LINES.each do |line|
      positions = [@board[line[0]], @board[line[1]], @board[line[2]]]
      if positions.count(marker) == 2 && positions.include?(BOARD_SIZE - 1)
        return line[positions.index(BOARD_SIZE - 1)]
      elsif positions.count(marker) == 2 && positions.include?(BOARD_SIZE)
        return line[positions.index(BOARD_SIZE)]
      elsif positions.count(marker) == 2 && positions.include?(BOARD_SIZE + 1)
        return line[positions.index(BOARD_SIZE + 1)]
      end
    end
    random_move
  end

  def random_move
    loop do
      position = rand(0..BOARD_SIZE - 1)
      return position if valid_move?(position)
    end
  end

  def play_again?
    puts 'Would you like to play again? (y/n)'
    input = gets.chomp.downcase
    if input == 'y'
      Game.new.start_game
    else
      puts 'Thanks for playing!'
      exit
    end
  end
end

Game.new.start_game
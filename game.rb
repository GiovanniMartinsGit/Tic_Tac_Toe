class Game
    BOARD_SIZE = 9
    WINNING_LINES = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
  
    def initialize
      @board = (1..BOARD_SIZE).to_a
      @computer1_marker = "X"
      @computer2_marker = "O"
      @player1_marker = "O"
      @player2_marker = "X"
      @current_player = 1
    end
  
    def start_game
      @computer_moved = false
      puts "Welcome to Tic Tac Toe!"
      puts "Enter 1 to play Multiplayer, 2 to play Solo against the computer, or 3 to watch the computer play against itself:"
      game_mode = gets.chomp.to_i
      if game_mode == 1
        puts "Let's start the game in Multiplayer mode!"
        puts "Player 1 will use 'O' and Player 2 will use 'X'."
      elsif game_mode == 2
        choose_difficulty
        puts "Let's start the game in Solo mode against the computer!"
        puts "You will use 'O' and the computer will use 'X'."
      elsif game_mode == 3
        puts "Let's watch the computer play against itself!"
        @current_player = [1, 2].sample 
      else
        puts "Invalid choice, please try again."
        start_game
        return
      end
      print_board
      until game_over? || tie?
        if game_mode == 1
          player_move
        elsif game_mode == 2
          if @level == 1
            if @current_player == 1
              player_move  
            else
              computer_move_easy
            end
          else
            if @current_player == 1
              player_move
            else
              computer_move
            end
          end
        elsif game_mode == 3
          computer_move
        end
        print_board
        @current_player = @current_player == 1 ? 2 : 1
      end
      if game_over?
        puts "Player #{winner} won the game!"
      elsif tie?
        puts "It's a tie!"
      end
      play_again?
    end
  
    private
  
    def choose_difficulty
      puts "Choose difficulty level:"
      puts "1. Easy"
      puts "2. Hard"
      @level = gets.chomp.to_i
      if @level == 1
        @computer_marker = @computer2_marker
        @computer_move_method = method(:computer_move_easy)
      elsif @level == 2
        @computer_marker = @computer1_marker
        @computer_move_method = method(:computer_move)
      else
        puts "Invalid choice, please try again."
        choose_difficulty
      end
    end
  
    def print_board
      puts ""
      (0..BOARD_SIZE-1).each_slice(3) do |row|
        puts row.map { |position| @board[position]}.join(" | ")
        puts "--+---+--" unless row == [6,7,8]
      end
      puts ""
    end
  
    def player_move
      marker = @current_player == 1 ? @player1_marker : @player2_marker
      player_num = @current_player == 1 ? "1" : "2"
      position = nil
      loop do
        puts "Player #{player_num}, enter a number between 1 and 9 to make your move:"
        position = gets.chomp.to_i - 1
        break if position.between?(0, BOARD_SIZE-1) && @board[position] !=[@computer1_marker, @computer2_marker] && @board[position] != @player1_marker && @board[position] != @player2_marker
        puts "Invalid move. Please try again. Only numbers from 1 to 9!"
      end
      @board[position] = marker
    end
  
    def computer_move
      position = nil
      markers = [@computer1_marker, @computer2_marker]
      markers.each do |marker|
        WINNING_LINES.each do |line|
          position = find_winning_move(line, marker)
          break if position && (@board[position] != @player1_marker && @board[position] != @player2_marker)
        end
        break if position
      end
      unless position
        available_spaces = @board.select { |pos| pos.is_a?(Integer) }
        position = available_spaces.sample
      end
      puts "Thinking..."
      sleep(1)
      if @board[position.to_i] == @computer1_marker || @board[position.to_i] == @computer2_marker || @board[position.to_i] == @player1_marker || @board[position.to_i] == @player2_marker
        puts "Invalid move, trying again"
        computer_move # Tenta de novo se a posição estiver ocupada
      else
        @board[position.to_i] = @current_player == 1 ? @player1_marker : @player2_marker
        puts "Computer move: #{position.to_i + 1}"
      end
    end
    
    def computer_move_easy
      position = nil
      markers = [@computer1_marker, @computer2_marker]
      markers.each do |marker|
        WINNING_LINES.each do |line|
          position = rand(1..9)
          break if position && (@board[position] != @player1_marker && @board[position] != @player2_marker)
        end
        break if position
      end
      unless position
        available_spaces = @board.select { |pos| pos.is_a?(Integer) }
        position = available_spaces.sample
      end
      puts "Thinking..."
      sleep(1)
      if @board[position.to_i] == @computer1_marker || @board[position.to_i] == @computer2_marker || @board[position.to_i] == @player1_marker || @board[position.to_i] == @player2_marker
        puts "Invalid move, trying again"
        computer_move # Tenta de novo se a posição estiver ocupada
      else
        @board[position.to_i] = @current_player == 1 ? @player1_marker : @player2_marker
        puts "Computer move: #{position.to_i + 1}"
      end
    end
  
    def find_winning_move(line, marker)
      if @board[line[0]] == marker && @board[line[1]] == marker && @board[line[2]].is_a?(Integer)
        return line[2]
      elsif @board[line[0]] == marker && @board[line[2]] == marker && @board[line[1]].is_a?(Integer)
        return line[1]
      elsif @board[line[1]] == marker && @board[line[2]] == marker && @board[line[0]].is_a?(Integer)
        return line[0]
      end
      return nil
    end
  
    def game_over?
      WINNING_LINES.any? do |line|
        markers_in_line = @board.values_at(*line)
        markers_in_line.all? { |marker| marker == @computer_marker } ||
          markers_in_line.all? { |marker| marker == @player1_marker } ||
          markers_in_line.all? { |marker| marker == @player2_marker }
      end
    end
  
     
    def tie?
      @board.all? { |position| position.is_a?(String) }
    end
  
    def winner
      WINNING_LINES.each do |line|
        markers_in_line = @board.values_at(*line)
        return "Player 1" if markers_in_line.all? { |marker| marker == @player1_marker }
        return "Player 2" if markers_in_line.all? { |marker| marker == @player2_marker }
        return "Computer 1" if markers_in_line.all? { |marker| marker == @computer1_marker }
        return "Computer 2" if markers_in_line.all? { |marker| marker == @computer2_marker }
      end
      nil
    end
  
    def play_again?
      puts "Do you want to play again? (Y/N)"
      answer = gets.chomp.downcase
      case answer
      when "y"
        Game.new.start_game
      when "n"
        return false
      else
        puts "Invalid input, please try again."
        play_again?
      end
    end
  
  end
  
  game = Game.new
  game.start_game
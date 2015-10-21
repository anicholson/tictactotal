module TicTacToe
  class Square
    VALID_STATES = [:EMPTY, :O, :X]

    attr_reader :state

    def initialize
      @state = :EMPTY
    end

    def valid?
      VALID_STATES.include? state
    end

    def empty?
      state == :EMPTY
    end

    def played?
      valid? && !empty?
    end

    def O
      @state = :O
    end

    def X
      @state = :X
    end

    def to_s
      empty? ? '.' : @state.to_s
    end
  end

  class Board
    class SquareAlreadyOccupiedError < Exception; end
    attr_reader :squares

    def initialize
      @squares = empty_board
    end

    def move(player, square)
      return if winner?
      return if full?

      square = @squares[square]
      unless square && square.empty?
        raise SquareAlreadyOccupiedError
      end

     square.send(player)
    end

    def empty?
      @squares.all?(&:empty?)
    end

    def full?
      @squares.none?(&:empty?)
    end

    def winner?
      winning_combinations = [
                              [0,1,2],
                              [3,4,5],
                              [6,7,8],
                              [0,3,6],
                              [1,4,7],
                              [2,5,8],
                              [0,4,8],
                              [2,4,6]
                             ]
      [:X, :O].each do |player|
        if winning_combinations.any? {|c| c.all? {|s| @squares[s].state == player }}
          return player
        end
      end
      return false
    end

    def to_s
      @squares.each_slice(3).map{|row| row.join " " }.join("\n")
    end

    private

    def empty_board
      9.times.map { |_| TicTacToe::Square.new }
    end
  end

  class Game
    attr_reader :board, :state

    STATES = [:NEW, :PLAYING, :WON, :DRAWN]

    def initialize
      @board          = Board.new
      @state          = :NEW
      @next_player    = :X
      @winning_player = nil
      @error          = nil
    end

    def move(square)
      return unless [:NEW, :PLAYING].include? @state

      @board.move(@next_player, square)
      update_game_state
      change_player_turn
    rescue => e
      @error = e
      puts e
    ensure
      # Sync DOM
    end

    private

    def change_player_turn
      @next_player = @next_player == :X ? :O : :X
    end

    def update_game_state
      if winner = @board.winner?
        @winning_player = winner
        @state = :WON
      elsif @board.full?
        @state = :DRAWN
      elsif @board.empty?
        @state = :NEW
      else
        @state = :PLAYING
      end
    end
  end

  game = Game.new

  (0..8).each do |square|
    game.move(square)
    puts game.board
    puts game.state
  end

  puts game.state

end

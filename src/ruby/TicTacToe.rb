require 'opal'
require 'opal-jquery'

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

    def O?
      @state == :O
    end

    def X
      @state = :X
    end

    def X?
      @state == :X
    end

    def to_s
      empty? ? '.' : @state.to_s
    end
  end

  class Board
    class SquareAlreadyOccupiedError < Exception
      def message
        "Square already occupied!"
      end
    end
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
    attr_reader :board, :state, :error, :winning_player

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
      clear_error_state
    rescue => e
      @error = e
    end

    private

    def clear_error_state
      @error = nil
    end

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

  class HTMLTicTacToe
    SQUARE_SELECTOR = '.square'
    WINNER_SELECTOR = '#messages .winner'
    ERROR_SELECTOR  = '#messages .error'
    NEW_GAME_BUTTON = 'button.new-game'

    def initialize
      @game = Game.new
    end

    def syncDOM
      display_error_messages
      display_status_messages
      update_board
    end

    def display_error_messages
      error_div = ::Element[ERROR_SELECTOR]
      if @game.error
        error_div.html @game.error.message
      else
        error_div.html ''
      end
    end

    def display_status_messages
      winner_div = ::Element[WINNER_SELECTOR]

      if @game.state == :WON
        winner_div.html "Player #{@game.winning_player} wins!"
      end

      if @game.state == :DRAWN
        winner_div.html "It's a tie."
      end
    end

    def update_board
      model_squares = @game.board.squares #Sorry Demeter
      dom_squares   = ::Element[SQUARE_SELECTOR].to_a

      model_squares.zip(dom_squares).each do |pair|
        model, dom = pair
        dom.class_name = "square #{model.state.downcase}"
      end
    end

    def setup_event_handlers
      syncDOM

      ::Element.find(SQUARE_SELECTOR).on :click do |event|
        target = ::Element[event.current_target]

        square = target.data 'position'

        if square
          @game.move(square)
          syncDOM
        end
      end

      ::Element.find('button.new-game').on :click do |_event|
        @game = Game.new
        syncDOM
      end
    end
  end
end

Document.ready? do
  driver = TicTacToe::HTMLTicTacToe.new
  driver.setup_event_handlers
end

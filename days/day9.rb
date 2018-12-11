require_relative '_init.rb'

#431 players; last marble is worth 70950 points
PUZZLE_PLAYERS = 431.freeze
PUZZLE_MAX_MARBLE = 70950.freeze
TEST_PLAYERS = 9.freeze
TEST_MAX_MARBLE = 25.freeze

class MarbleGame
  attr_accessor :player_count
  attr_accessor :max_marble
  attr_accessor :scores
  attr_accessor :marble_number
  attr_accessor :last_placed_marble
  attr_accessor :turns
  attr_accessor :board
  attr_accessor :current_player

  SPECIAL_NUMBER = 23.freeze

  def initialize(player_count:, max_marble:)
    self.player_count = player_count
    self.max_marble = max_marble
    self.marble_number = 1
    self.scores = {}
    self.turns = [[0]]
    self.board = [0]
    self.last_placed_marble = 0
    self.current_player = 1
  end

  def play
    while self.marble_number <= self.max_marble
      place_marble(self.current_player)
      change_player
    end
  end

  def place_marble(player)
    if special_marble?

    else

    end

    self.last_placed_marble = self.marble_number
    self.marble_number += 1
    self.turns << self.board.dup
  end

  def special_marble?
    self.marble_number % MarbleGame::SPECIAL_NUMBER == 0
  end

  def change_player
    if self.current_player == self.player_count
      self.current_player = 1
    else
      self.current_player += 1
    end
    self.current_player
  end
end

binding.pry
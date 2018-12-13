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
  SPECIAL_WALKBACK = 7.freeze

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
      p "Placing marble #{self.marble_number}"
      place_marble(self.current_player)
      change_player
    end
  end

  def place_marble(player)
    if special_marble?
      special_place_marble(player)
    else
      standard_place_marble
    end

    self.marble_number += 1
    # This is stupid slow after about 20k turns
    # Maybe try Set?
    #self.turns << self.board.dup
  end

  def standard_place_marble
    last_index = self.board.find_index(self.last_placed_marble)
    if last_index == (self.board.count - 1)
      #last placed marble is at the end of the array
      self.board.insert(1, self.marble_number)
    elsif last_index == (self.board.count - 2)
      #this marble needs to be added to the array at the end
      self.board << self.marble_number
    else
      self.board.insert((last_index + 2), self.marble_number)
    end

    self.last_placed_marble = self.marble_number
    self.board
  end

  def special_place_marble(player)
    score_points(player, self.marble_number)
    last_index = self.board.find_index(self.last_placed_marble)

    if last_index >= MarbleGame::SPECIAL_WALKBACK
      target_index = last_index - MarbleGame::SPECIAL_WALKBACK
    else
      target_index = (self.board.count - 1) - (last_index - MarbleGame::SPECIAL_WALKBACK).abs
    end

    score_points(player, self.board.delete_at(target_index))

    self.last_placed_marble = self.board[target_index]
    self.board
  end

  def special_marble?
    self.marble_number % MarbleGame::SPECIAL_NUMBER == 0
  end

  def score_points(player, points)
    scores[player] ||= 0
    scores[player] += points
  end

  def change_player
    if self.current_player == self.player_count
      self.current_player = 1
    else
      self.current_player += 1
    end
    self.current_player
  end

  def winner
    player = self.scores.key(self.scores.values.max)
    { player: player, score: self.scores[player] }
  end
end

def process
  game = MarbleGame.new(player_count: PUZZLE_PLAYERS, max_marble: PUZZLE_MAX_MARBLE)
  game.play
  game
end

def test
  game = MarbleGame.new(player_count: TEST_PLAYERS, max_marble: TEST_MAX_MARBLE)
  game.play

  raise "BAD SCORES - #{game.scores}" unless game.scores == {5=>32}
  raise "BAD FINAL BOARD STATE - #{game.board}" unless game.board == [0, 16, 8, 17, 4, 18, 19, 2, 24, 20, 25, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15]

  game
end

test
res = process
p "PART 1:"
# 400535 is too low
p res.winner


binding.pry
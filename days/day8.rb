require_relative '_init.rb'

PUZZLE_INPUT = File.read('day8_input.txt').split(' ').map(&:to_i).freeze
TEST_INPUT = '2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2'.split(' ').map(&:to_i).freeze

class StateManager
  def self.current_input=(input)
    @@current_input = input
  end

  def self.current_input
    @@current_input
  end

  def self.current_index=(index)
    @@current_index = index
  end

  def self.current_index
    @@current_index
  end

  def self.root_node=(node)
    @@root_node = node
  end

  def self.root_node
    @@root_node
  end

  def self.nodes=(nodes)
    @@nodes = nodes
  end

  def self.nodes
    @@nodes
  end

  def self.next_node_id=(id)
    @@next_node_id = id
  end

  def self.next_node_id
    @@next_node_id
  end

  def self.assign_next_node_id
    node_id = @@next_node_id
    @@next_node_id = @@next_node_id.succ
    node_id
  end

  def self.metadata_sum=(int)
    @@metadata_sum = int
  end

  def self.metadata_sum
    @@metadata_sum
  end

  def self.add_to_meta_sum(int)
    @@metadata_sum += int
  end

  def self.root_node_value=(int)
    @@root_node_value = int
  end

  def self.root_node_value
    @@root_node_value
  end

  def self.reset!
    StateManager.current_index = 0
    StateManager.current_input = nil
    StateManager.root_node = nil
    StateManager.nodes = []
    StateManager.next_node_id = 'A'
    StateManager.metadata_sum = 0
    StateManager.root_node_value = 0
  end
end

class TreeNode
  attr_accessor :id
  attr_accessor :children
  attr_accessor :metadata
  attr_accessor :header

  def initialize(id, header)
    self.id = id
    self.children = []
    self.metadata = []
    self.header = header
  end

  def add_child(node)
    self.children << node
  end

  def add_metadata(metadata)
    self.metadata << metadata
  end

end

def process(input_data)
  StateManager.reset!
  StateManager.current_input = input_data

  StateManager.root_node = load_node_at_current_index
end

def load_node_at_current_index
  node_child_count = StateManager.current_input[StateManager.current_index]
  StateManager.current_index += 1
  node_meta_count = StateManager.current_input[StateManager.current_index]
  StateManager.current_index += 1
  node_header = [node_child_count, node_meta_count]

  node = TreeNode.new(StateManager.assign_next_node_id, node_header)

  node_child_count.times do
    node.add_child(load_node_at_current_index)
  end

  node_meta_count.times do
    meta = StateManager.current_input[StateManager.current_index]
    StateManager.add_to_meta_sum(meta)
    node.add_metadata(meta)
    StateManager.current_index += 1
  end

  node
end

def test
  res = process(TEST_INPUT)
  raise "BAD PARSE" unless res.to_json == "{\"id\":\"A\",\"children\":[{\"id\":\"B\",\"children\":[],\"metadata\":[10,11,12],\"header\":[0,3]},{\"id\":\"C\",\"children\":[{\"id\":\"D\",\"children\":[],\"metadata\":[99],\"header\":[0,1]}],\"metadata\":[2],\"header\":[1,1]}],\"metadata\":[1,1,2],\"header\":[2,3]}"
  raise "BAD SUM - #{StateManager.metadata_sum}" unless StateManager.metadata_sum == 138
  res
end

p "PART 1:"
process(PUZZLE_INPUT)
p StateManager.metadata_sum


#PART 2

def process_2(input_data)
  process(input_data)
  StateManager.root_node_value = calculate_node_value(StateManager.root_node)
end

def calculate_node_value(node)
  total = 0
  #p "Processing #{node.id}"
  if node.children.any?
    #p "has children"
    node.metadata.each do |possible_index|
      possible_index -= 1
      #p "Checking if node has child at #{possible_index}"
      possible_node = node.children[possible_index]
      if possible_node.present?
        #p "FOUND NODE"
        total += calculate_node_value(possible_node)
      end
    end
  else
    #p "No children - #{node.metadata.sum}"
    total += node.metadata.sum
  end

  total
end

def test_2
  res = process_2(TEST_INPUT)
  raise "WRONG NODE VALUE - #{StateManager.root_node_value}" unless StateManager.root_node_value == 66
end

test_2
process_2(PUZZLE_INPUT)
p "PART 2:"
p StateManager.root_node_value

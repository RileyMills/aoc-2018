require_relative '_init.rb'

PUZZLE_INPUT = File.read('day7_input.txt').split("\n").freeze
TEST_INPUT = 'Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.'.split("\n").freeze

class InstructionStep
  attr_accessor :letter
  attr_accessor :ancestors
  attr_accessor :children
  attr_accessor :completed
  attr_accessor :base_execution_time

  DEFAULT_EXECUTION_TIME = 60.freeze

  @@known_steps = {}
  @@first_step = nil

  def initialize(letter:, base_execution_time: InstructionStep::DEFAULT_EXECUTION_TIME)
    #parsed = InstructionStep.parse_step_string(step_string)
    #constructed = InstructionStep.construct_from_parsed_step(parsed)
    self.letter = letter
    self.completed = false
    self.ancestors = []
    self.children = []
    self.base_execution_time = base_execution_time

    @@known_steps[letter] ||= self
    self
  end

  def self.reset!
    @@known_steps = {}
    @@first_step = nil
  end

  def self.parse_step_string(str)
    split = str.split(' ')
    step_letter = split[7]
    previous_step = split[1]
    { step_letter: step_letter, previous_step: previous_step }
  end

  def self.construct_from_step_string(step_string:, base_execution_time: InstructionStep::DEFAULT_EXECUTION_TIME)
    self.construct_from_parsed_step(parsed_step: self.parse_step_string(step_string), base_execution_time: base_execution_time)
  end

  def self.construct_from_parsed_step(parsed_step:, base_execution_time: InstructionStep::DEFAULT_EXECUTION_TIME)
    step = InstructionStep.find_or_initialize_by(letter: parsed_step[:step_letter], base_execution_time: base_execution_time)
    step.add_ancestor_by_letter(letter: parsed_step[:previous_step], base_execution_time: base_execution_time)
  end

  def self.find_or_initialize_by(letter:, base_execution_time: InstructionStep::DEFAULT_EXECUTION_TIME)
    step = InstructionStep.get_step(letter)
    step.present? ? step : InstructionStep.new(letter: letter, base_execution_time: base_execution_time)
  end

  def self.known_steps
    @@known_steps
  end

  def known_steps
    @@known_steps
  end

  def self.get_step(step_letter)
    @@known_steps[step_letter]
  end

  def self.first_step
    @@first_step
  end

  def first_step
    @@first_step
  end

  def add_ancestor_by_letter(letter:, base_execution_time: InstructionStep::DEFAULT_EXECUTION_TIME)
    previous_step = InstructionStep.find_or_initialize_by(letter: letter, base_execution_time: base_execution_time)
    previous_step.add_child(self)
    add_ancestor(previous_step)
    self
  end

  def add_ancestor(ancestor)
    self.ancestors << ancestor
    @@first_step = ancestor if @@first_step.nil?
    self
  end

  def add_child(child)
    self.children << child
    self
  end

  def complete!
    if can_complete?
      self.completed = true
    else
      raise 'Cannot complete yet, ancestors are pending.'
    end
    self
  end

  def completed?
    self.completed
  end

  def can_complete?
    #p "Checking if can complete step #{self.letter}"
    self.ancestors.map{ |x| x.completed? }.all?
  end

  def execution_time
    #NOTE - This will ONLY work with single-letter step IDs
    self.letter.upcase.ord - 'A'.ord + 1 + self.base_execution_time
  end
end

class InstructionRunner
  attr_accessor :steps
  attr_accessor :pending_steps
  attr_accessor :step_order
  attr_accessor :complete

  def initialize(steps)
    self.steps = steps
    self.pending_steps = []

    steps.each do |letter, step|
      self.pending_steps << step
    end

    self.step_order = []
    self.complete = false
    self
  end

  def complete?
    self.complete
  end

  def run_steps
    i = 0

    until self.complete do
      possible_steps = []
      self.pending_steps.each do | step |
        #p "Checking step - #{step.letter}"
        if step.completed?
          p "FOUND COMPLETED BUT UNREMOVED STEP - #{step.letter}"
          remove_step(step)
        elsif step.can_complete?
          possible_steps << step
        end
      end

      step = determine_next_step(possible_steps)
      step.complete!
      self.step_order << step.letter
      remove_step(step)

      if pending_steps.empty?
        self.complete = true
      end

      i += 1
      if i > 5000
        p "WE HIT 5k iterations...."
        raise "INFINITE LOOP"
      end
    end

    self.step_order
  end

  def determine_next_step(possible_steps)
    return possible_steps.sort{ |x,y| x.letter <=> y.letter }.first
  end

  def remove_step(step)
    self.pending_steps.delete(step)
  end

end

def process(input_data)
  instructions = []
  input_data.each do |input|
    instructions << InstructionStep.construct_from_step_string(step_string: input)
  end
  instructions
end

def test
  res = process(TEST_INPUT)

  raise "WRONG FIRST STEP = #{InstructionStep.first_step.letter}" unless InstructionStep.first_step.letter == 'C'
  raise "FIRST STEP HAS ANCESTORS!" unless InstructionStep.first_step.ancestors.empty?

  runner = InstructionRunner.new(InstructionStep.known_steps)
  runner.run_steps

  raise "WRONG ORDER - #{runner.step_order}" unless runner.step_order == ["C", "A", "B", "D", "F", "E"]
end

def step_1
  process(PUZZLE_INPUT)
  runner = InstructionRunner.new(InstructionStep.known_steps)
  runner.run_steps
end

test()
InstructionStep.reset!

p "PART 1:"
p step_1().join('')
InstructionStep.reset!


#PART 2

class WorkerElf
  attr_accessor :id
  attr_accessor :processing_step
  attr_accessor :time_left
  attr_accessor :idle

  def initialize(id:)
    self.id = id
    self.idle = true
    self.time_left = 0
  end

  def tick
    return if self.idle?
    self.time_left -= 1
  end

  def assign_step(step)
    self.processing_step = step
    self.time_left = step.execution_time
    self.idle = false
  end

  def go_idle
    self.idle = true
    self.processing_step.complete!
    self.processing_step = nil
  end

  def idle?
    self.idle
  end

end

class ThreadedInstructionRunner
  attr_accessor :steps
  attr_accessor :pending_steps
  attr_accessor :processing_steps
  attr_accessor :step_order
  attr_accessor :complete
  attr_accessor :workers
  attr_accessor :second

  def initialize(steps, worker_count = 5)
    self.steps = steps
    self.pending_steps = []
    self.processing_steps = []
    self.workers = []
    self.second = 0

    steps.each do |letter, step|
      self.pending_steps << step
    end

    self.step_order = []
    self.complete = false

    worker_count.times do |i|
      self.workers << WorkerElf.new(id: (i + 1))
    end

    self
  end

  def complete?
    self.complete
  end

  def run_steps
    print_header
    until self.complete do
      possible_steps = []
      self.pending_steps.each do | step |
        #p "Checking step - #{step.letter}"
        if step.completed?
          p "FOUND COMPLETED BUT UNREMOVED STEP - #{step.letter}"
          remove_step(step)
        elsif step.can_complete?
          possible_steps << step
        end
      end

      assign_work(possible_steps)
      print_state
      tick

      if pending_steps.empty? && processing_steps.empty?
        self.complete = true
      end

      self.second += 1
      if self.second > 5000
        p "WE HIT 5k iterations...."
        raise "INFINITE LOOP"
      end
    end

    print_state

    self.step_order
  end

  def assign_work(possible_steps)
    selected_steps = possible_steps.sort{ |x,y| x.letter <=> y.letter }
    selected_steps.each do |step|
      workers.each do |worker|
        if worker.idle?
          worker.assign_step(step)
          processing_steps << step
          remove_step(step)
          break
        end
      end
    end
  end

  def clear_work
    workers.each do |worker|
      if worker.idle?
        worker.assign_step(step)
        processing_steps << step
        remove_step(step)
        break
      end
    end
  end

  def tick
    workers.each do |worker|
      time_left = worker.tick

      if time_left == 0
        worker_step = worker.processing_step
        worker.go_idle
        worker_step.complete!
        self.step_order << worker_step.letter
        remove_processing_step(worker_step)
      end
    end
  end

  def print_header
    headers = ['Second']
    workers.count.times do | i |
      headers << "Worker #{i + 1}"
    end
    #headers << 'Done'
    printf headers.map{|x| x.ljust(10)}.join + 'Done'.ljust(30) + "\n"
  end

  def print_state
    line = ["#{self.second}"]
    workers.each do |worker|
      text = worker.idle? ? '.' : worker.processing_step.letter
      line << text
    end
    #line << self.step_order.join
    printf line.map{|x| x.ljust(10)}.join + self.step_order.join.ljust(30) + "\n"
  end

  def remove_step(step)
    self.pending_steps.delete(step)
  end

  def remove_processing_step(step)
    self.processing_steps.delete(step)
  end

end

def process_2(input_data, base_execution_time = InstructionStep::DEFAULT_EXECUTION_TIME)
  instructions = []
  input_data.each do |input|
    instructions << InstructionStep.construct_from_step_string(step_string: input, base_execution_time: base_execution_time)
  end
  instructions
end

def test_2
  res = process_2(TEST_INPUT, 0)

  runner = ThreadedInstructionRunner.new(InstructionStep.known_steps, 2)
  runner.run_steps

  raise "WRONG ORDER - #{runner.step_order}" unless runner.step_order == ["C", "A", "B", "F", "D", "E"]
  raise "WRONG SECOND COUNT - #{runner.second}" unless runner.second == 15
  runner
end

def step_2
  process_2(PUZZLE_INPUT)
  runner = ThreadedInstructionRunner.new(InstructionStep.known_steps, 5)
  runner.run_steps
  runner
end

p "PART 2:"
test_2
InstructionStep.reset!
runner = step_2
p "PART 2 ANSWER:"
p runner.second


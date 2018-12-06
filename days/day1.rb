require_relative '_init.rb'

puzzle_input = File.read('day1_input.txt').split("\n")
parsed_input = puzzle_input.map{ |x| x.to_i }
parsed_input2 = puzzle_input.map{ |x| x.to_i }

#PART 1
test_data = [[%w(+1, +1, +1), 3], [%w(+1, +1, -2), 0], [%w(-1, -2, -3), -6]]

def process(input_data)
  input_data.inject(&:+)
end

def test(test_data)
  test_data.each do | td, expected |
    processed = process(td.map{ |x| x.to_i })
    unless processed.eql? expected
      raise "#{td.inspect} did not equal #{expected}, got #{processed}"
    end
  end
end

#PART 2
test_data_2 = [[%w(+1, -1), 0],
               [%w(+3, +3, +4, -2, -4), 10],
               [%w(-6, +3, +8, +5, -6), 5],
               [%w(+7, +7, -2, -7, -4), 14]]

test_data_2_2 = [[%w(+1, -1), 0],
               [%w(+3, +3, +4, -2, -4), 10],
               [%w(-6, +3, +8, +5, -6), 5],
               [%w(+7, +7, -2, -7, -4), 14]]

# ~91.7 seconds
def process_2(input_data)
  seen_totals = [0]
  total = 0

  while true do
    total += input_data.first
    return total if seen_totals.include?(total)
    seen_totals << total
    input_data.rotate!
  end
end

# ~69 seconds
def process_2_2(input_data)
  seen_totals = [0]
  total = 0
  index = 0
  max = input_data.count - 1
  loops = 0

  #Benchmark.bm do |y|
    while true do
      #y.report("Interation: #{loops}") {
        total += input_data[index]
        return total if seen_totals.include?(total)
        seen_totals << total
        index += 1
        index = 0 if index > max
        loops += 1
      #}
    end
  #end

end

# ~0.041111 seconds :lol:
def process_2_3(input_data)
  seen_totals = [0].to_set
  total = 0
  index = 0
  max = input_data.count - 1
  loops = 0

  #Benchmark.bm do |y|
    while true do
      #y.report("Interation: #{loops}") {
        total += input_data[index]
        return total if seen_totals.include?(total)
        seen_totals << total
        index += 1
        index = 0 if index > max
        loops += 1
      #}
    end
  #end

end

def test_2(test_data)
  test_data.each do | td, expected |
    processed = process_2(td.map{ |x| x.to_i })
    unless processed.eql? expected
      raise "#{td.inspect} did not equal #{expected}, got #{processed}"
    end
  end
end

def test_2_2(test_data)
  test_data.each do | td, expected |
    processed = process_2_2(td.map{ |x| x.to_i })
    unless processed.eql? expected
      raise "#{td.inspect} did not equal #{expected}, got #{processed}"
    end
  end
end

test(test_data)
test_2(test_data_2)
test_2_2(test_data_2_2)

p 'Answer for Part 1:'
p process(parsed_input)
p ''
p 'Answer for Part 2:'
p process_2_3(parsed_input2)

#Benchmark.bm do |x|
  #x.report { p process_2(puzzle_input.map{ |x| x.to_i }) }
  #x.report { p process_2_2(puzzle_input.map{ |x| x.to_i }) }
  #x.report { p process_2_3(puzzle_input.map{ |x| x.to_i }) }
#end

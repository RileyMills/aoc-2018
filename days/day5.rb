require_relative '_init.rb'

puzzle_input = File.read('day5_input.txt')
TEST_INPUT = 'dabAcCaCBAcCcaDA'.freeze

MAIN_REGEX_A = /[a-z][A-Z]/
MAIN_REGEX_B = /[A-Z][a-z]/

PAIRS = []
('a'..'z').each do |letter|
  PAIRS << ["#{letter}#{letter.upcase}", "#{letter.upcase}#{letter}"]
end

def get_matches(str)
  matches_a = str.to_enum(:scan, MAIN_REGEX_A).map { Regexp.last_match }
  matches_a.delete_if{ |match| !valid_pair?(match.to_s) }
  matches_b = str.to_enum(:scan, MAIN_REGEX_B).map { Regexp.last_match }
  matches_b.delete_if{ |match| !valid_pair?(match.to_s) }
  matches_a + matches_b
end

def valid_pair?(str)
  raise "NOT TWO CHARS - #{str}" unless str.length == 2
  str[0].downcase == str[1].downcase
end

# ~5.85 seconds
def process(str)
  output = str.dup

  while true do
    matches = get_matches(output)
    break if matches.empty?

    matches.each do | match_data |
      output.slice!(match_data.to_s)
    end
  end

  output
end

# ~0.16 seconds
def process_1_2(str)
  output = str.dup
  output_length = output.length

  while true do
    PAIRS.each do |pair|
      output.gsub!(pair[0], '')
      output.gsub!(pair[1], '')
    end

    break if output.length == output_length
    output_length = output.length
  end

  output
end

def test
  res = process(TEST_INPUT)
  raise "TEST RESULT STRING WRONG - #{res}" unless res == 'dabCBAcaDA'
end

def test_1_2
  res = process_1_2(TEST_INPUT)
  raise "TEST RESULT STRING WRONG - #{res}" unless res == 'dabCBAcaDA'
end

test()
test_1_2()

p "PART 1 ANSWER:"
#p process(puzzle_input).length
p process_1_2(puzzle_input).length

#Benchmark.bm do |x|
#  x.report { p process(puzzle_input).length }
#  x.report { p process_1_2(puzzle_input).length }
#end



#PART 2

def process_2(str)
  output = { letter: '', string: '' }
  shortest_length = str.length
  original_length = str.length

  ('a'..'z').each do |letter|
    test_str = str.dup
    test_str.tr!(letter, '')
    test_str.tr!(letter.upcase, '')

    next if test_str.length == original_length

    test_str = process_1_2(test_str)
    if test_str.length < shortest_length
      shortest_length = test_str.length
      output[:string] = test_str.dup
      output[:letter] = letter
    end
  end

  output
end

def test_2
  res = process_2(TEST_INPUT)

  raise "PICKED WRONG LETTER! - #{res[:letter]}" unless res[:letter] == 'c'
  raise "BAD RESULT STRING! - #{res[:string]}" unless res[:string] == 'daDA'
end

test_2

p "PART 2 ANSWER:"
result = process_2(puzzle_input)
p result[:string].length

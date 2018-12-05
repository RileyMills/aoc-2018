require_relative '_init.rb'

puzzle_input = File.read('day2_input.txt').split("\n")
parsed_input = puzzle_input.map{ |x| x.split('') }

#PART 1
test_data = %w(abcdef
bababc
abbcde
abcccd
aabcdd
abcdee
ababab).map{ |x| x.split('') }

def process(input_data)
  doubles = 0
  triples = 0

  input_data.each do |datum|
    seen_letters = {}
    double = false
    triple = false
    datum.each do | letter |
      seen_letters[letter] ||= 0
      seen_letters[letter] += 1
    end

    seen_letters.each do |_, count|
      if count == 2
        double = true
      elsif count == 3
        triple = true
      end
    end

    doubles += 1 if double
    triples += 1 if triple
  end

  doubles * triples
end

def test(test_data)
  result = process(test_data)
  raise "Result wrong, got #{result} instead of 12" unless result == 12
end


#PART 2
test_data_2 = %w(abcde
fghij
klmno
pqrst
fguij
axcye
wvxyz).map{ |x| x.split('') }

def process_2(input_data)
  input_data.each do |datum|
    input_data.each do |check|
      delta = 0
      delta_index = -1

      datum.each_with_index do |letter, index|
        unless check[index] == letter
          delta += 1
          delta_index = index
        end
      end

      if delta == 1
        datum.delete_at(delta_index)
        return datum.join
      end
    end
  end
end

def test_2(test_data)
  result = process_2(test_data)
  raise "Result wrong, got #{result} instead of 'fgij'" unless result == 'fgij'
end

test(test_data)
test_2(test_data_2)

p 'ANSWER 1:'
p process(parsed_input)
p ''
p 'ANSWER 2:'
p process_2(parsed_input)

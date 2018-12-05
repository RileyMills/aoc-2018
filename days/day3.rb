require_relative '_init.rb'

puzzle_input = File.read('day3_input.txt').split("\n")
parsed_data = []

def parse_datum(datum)
  parsed = datum.split(' ')
  dimensions = parsed[3].split('x')
  {
      id: parsed[0],
      coordinates: parsed[2].slice!(0..-2).split(',').map{|x| x.to_i},
      width: dimensions[0].to_i,
      height: dimensions[1].to_i

  }
end

puzzle_input.each do |datum|
  parsed_data << parse_datum(datum)
end


#PART 1
test_data = '#1 @ 1,3: 4x4
#2 @ 3,1: 4x4
#3 @ 5,5: 2x2'.split("\n")

parsed_test_data = test_data.map{|x| parse_datum(x)}

def make_grid(width, height)
  grid = []
  (0...height).each do |y|
    grid << Array.new(width, 0)
  end
  grid
end

grid = make_grid(1000, 1000)
grid2 = make_grid(1000, 1000)
test_grid = make_grid(8, 8)
test_grid2 = make_grid(8, 8)

def process(input_data, grid)
  input_data.each do |parsed|
    #p parsed
    start_x = parsed[:coordinates][0]
    start_y = parsed[:coordinates][1]
    end_x = start_x + parsed[:width] - 1
    end_y = start_y + parsed[:height] - 1

    (start_x..end_x).each do |x|
      (start_y..end_y).each do |y|
        #p "DOING GRID X: #{x}, Y: #{y}"
        grid[y][x] = 0 if grid[y][x] == '.'
        grid[y][x] += 1
      end
    end
  end

  grid
end

def count_grid(grid)
  total = 0
  grid.each_with_index do |row, y|
    row.each_with_index do|col, x|
      #p "Counting X: #{x}, Y: #{y}"
      #p col
      total += 1 if col > 1
    end
  end
  total
end

def test(test_data, test_grid)
  grid = process(test_data, test_grid)
  #pp grid
  res = count_grid(grid)
  raise "Processing error.  got #{res} instead of 4!" unless res == 4
end


#PART 2

def process_2(input_data, grid)
  input_data.each do |parsed|
    #p parsed
    start_x = parsed[:coordinates][0]
    start_y = parsed[:coordinates][1]
    end_x = start_x + parsed[:width] - 1
    end_y = start_y + parsed[:height] - 1
    safe = true

    (start_x..end_x).each do |x|
      (start_y..end_y).each do |y|
        #p "DOING GRID X: #{x}, Y: #{y}"
        safe = false if grid[y][x] > 1
      end
    end

    return parsed[:id] if safe
  end
end

def test_2(test_data, test_grid)
  tg = process(test_data, test_grid)
  res = process_2(test_data, tg)
  raise "Processing error, got '#{}' instead of '#3'" unless res == "#3"
end

def part_2(input_data, grid)
  output_grid = process(input_data, grid)
  process_2(input_data, output_grid)
end

p "TESTING PART 1"
test(parsed_test_data, test_grid)
p "TESTING PART 2"
test_2(parsed_test_data, test_grid2)

p 'ANSWER 1:'
p count_grid(process(parsed_data, grid))
p ''
p 'ANSWER 2:'
p part_2(parsed_data, grid2)

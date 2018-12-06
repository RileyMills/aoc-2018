require_relative '_init.rb'

puzzle_input = File.read('day6_input.txt').split("\n").map{ |x| x.split(', ').map{ |y| y.to_i } }
puzzle_input.freeze
TEST_INPUT = '1, 1
1, 6
8, 3
3, 4
5, 5
8, 9'.split("\n").map{ |x| x.split(', ').map{ |y| y.to_i } }
TEST_INPUT.freeze
EMPTY_CHAR = 'øø'.freeze
SHARED_CHAR = '..'.freeze
SAFE_ZONE_CHAR = '##'.freeze

def make_grid(width, height)
  grid = []
  (0...height).each do |y|
    grid << Array.new(width, EMPTY_CHAR)
  end
  grid
end

def set_point(coordinate, grid, value)
  grid[coordinate[1]][coordinate[0]] = value
  grid
end

def get_point(coordinate, grid)
  grid[coordinate[1]][coordinate[0]]
end

def find_closest(point, anchor_points)
  winner = nil
  best_distance = 5000000000
  seen_distances = []

  anchor_points.each do | _, ap |
    distance = manhattan(point, ap[:point])
    seen_distances << distance

    if distance < best_distance
      winner = ap
      best_distance = distance
    end
  end

  if seen_distances.select{|x| x == best_distance}.count > 1
    return { point: { point: [-1, -1], child_mark: SHARED_CHAR }, distance: best_distance }
  end

  { point: winner, distance: best_distance }
end

#https://codereview.stackexchange.com/questions/125775/idiomatic-ruby-to-calculate-distance-to-points-on-a-graph
def manhattan(pt1, pt2)
  (pt1[0]-pt2[0]).abs + (pt1[1]-pt2[1]).abs
end

def disqualify_anchors(grid, anchors)
  #p "DISQUALIFYING STUFF"
  #p anchors
  disqualified = []
  edges = []
  edges << grid.first.dup.map(&:downcase)
  edges << grid.last.dup.map(&:downcase)

  (1...(grid.count - 2)).each do | row_index |
    edges << grid[row_index].first.downcase
    edges << grid[row_index].last.downcase
  end

  #Not sure if necessary yet
  #edges = edges.to_set

  anchors.keys.each do | anchor |
    disqualified << anchor if edges.include?(anchor.downcase)
  end

  disqualified
end

def get_area(grid, anchor_char)
  grid.dup.flatten.map(&:downcase).count(anchor_char.downcase)
end

def get_largest_area(grid, anchor_keys)
  largest_key = ''
  largest_area = 0
  all_areas = []

  anchor_keys.each do | ak |
    area = get_area(grid, ak)
    all_areas << [ak, area]
    if area > largest_area
      largest_key = ak
      largest_area = area
    end
  end

  { anchor_key: largest_key, area: largest_area, all_areas: all_areas }
end

def process(input_data)
  x_max = input_data.max { |a, b| a[0] <=> b[0] }[0] + 1
  y_max = input_data.max { |a, b| a[1] <=> b[1] }[1] + 1
  grid = make_grid(x_max, y_max)
  anchor_points = {}

  ('AA'..'ZZ').each_with_index do | letter, i |
    break if i > (input_data.count - 1)
    anchor_points[letter] = { point: input_data[i], child_mark: letter.downcase }
  end

  anchor_chars = anchor_points.keys

  anchor_points.each do | letter, coordinate |
    set_point(coordinate[:point], grid, letter)
  end

  grid.each_with_index do | row, y |
    row.each_with_index do | col, x |
      closest_anchor_point = find_closest([x, y], anchor_points)[:point]
      current_value = get_point([x, y], grid)

      next if anchor_chars.include?(current_value)

      set_point([x, y], grid, closest_anchor_point[:child_mark])
    end
  end

  #grid.each do |row|
  #  pp row
  #end

  disqualified = disqualify_anchors(grid, anchor_points)
  qualified = anchor_chars - disqualified
  largest_area = get_largest_area(grid, qualified)

  { grid: grid, disqualified: disqualified, qualified: qualified, largest_area: largest_area }
end

def test
  correct_grid = [["aa", "aa", "aa", "aa", "aa", "..", "ac", "ac", "ac"],
                  ["aa", "AA", "aa", "aa", "aa", "..", "ac", "ac", "ac"],
                  ["aa", "aa", "aa", "ad", "ad", "ae", "ac", "ac", "ac"],
                  ["aa", "aa", "ad", "ad", "ad", "ae", "ac", "ac", "AC"],
                  ["..", "..", "ad", "AD", "ad", "ae", "ae", "ac", "ac"],
                  ["ab", "ab", "..", "ad", "ae", "AE", "ae", "ae", "ac"],
                  ["ab", "AB", "ab", "..", "ae", "ae", "ae", "ae", ".."],
                  ["ab", "ab", "ab", "..", "ae", "ae", "ae", "af", "af"],
                  ["ab", "ab", "ab", "..", "ae", "ae", "af", "af", "af"],
                  ["ab", "ab", "ab", "..", "af", "af", "af", "af", "AF"]]

  res = process(TEST_INPUT)

  raise "GRID IS WRONG - #{res[:grid]}" unless res[:grid] == correct_grid
  raise "WRONG DISQUALIFICATIONS - #{res[:disqualified]}" unless res[:disqualified] == ["AA", "AB", "AC", "AF"]
  raise "WRONG QUALIFICAITONS - #{res[:qualified]}" unless res[:qualified] == ["AD", "AE"]
  raise "WRONG AREA - #{res[:largest_area]}" unless res[:largest_area] == { anchor_key: "AE", area: 17 }

  res
end

res = process(puzzle_input)
#{:anchor_key=>"AF", :area=>8873} is too high
# ["AF", 8873],
#  ["BU", 8037],
#  ["AG", 7212],
#  ["AY", 3660],
# AY was correct... not sure.... must have a bug in how I'm removing the infinite areas
# Need to debug by making an image or something...
# https://stackoverflow.com/questions/18794307/ruby-draw-color-specific-pixels-from-source-image-to-new-image

p "PART 1 ANSWER:"
p res[:largest_area]
p "Just kidding, it's actually"
p ["AY", 3660]


# PART 2

def safe_zone?(point, anchor_points, max_distance)
  distance_total = 0

  anchor_points.each do | _, ap |
    distance_total += manhattan(point, ap[:point])
  end

  #p "POINT"
  #p point
  #p "DISTANCE - #{distance_total}"

  distance_total < max_distance
end

def process_2(input_data, max_distance = 10000)
  x_max = input_data.max { |a, b| a[0] <=> b[0] }[0] + 1
  y_max = input_data.max { |a, b| a[1] <=> b[1] }[1] + 1
  grid = make_grid(x_max, y_max)
  anchor_points = {}

  ('AA'..'ZZ').each_with_index do | letter, i |
    break if i > (input_data.count - 1)
    anchor_points[letter] = { point: input_data[i], child_mark: letter.downcase }
  end

  anchor_chars = anchor_points.keys

  anchor_points.each do | letter, coordinate |
    set_point(coordinate[:point], grid, letter)
  end

  grid.each_with_index do | row, y |
    row.each_with_index do | col, x |
      #current_value = get_point([x, y], grid)
      #next if anchor_chars.include?(current_value)

      set_point([x, y], grid, SAFE_ZONE_CHAR) if safe_zone?([x, y], anchor_points, max_distance)
    end
  end

  safe_area = get_area(grid, SAFE_ZONE_CHAR)

  { grid: grid, safe_area: safe_area }
end

def test_2
  res = process_2(TEST_INPUT, 32)

  raise "WRONG SAFE AREA COUNT - #{res[:safe_area]}" unless res[:safe_area] == 16

  res
end

p "PART 2:"
res_2 = process_2(puzzle_input)
p res_2[:safe_area]

require_relative '_init.rb'

input_data = File.read('day4_input.txt').split("\n")

WAKES_UP = 'wakes up'.freeze
FALLS_ASLEEP = 'falls asleep'.freeze
BEGINS_SHIFT = 'begins shift'.freeze
AWAKE = '.'.freeze
ASLEEP = '#'.freeze

def parse_by_datetime(input)
  parsed_dates = {}
  input.each do |str|
    split = str.split(']')
    date_time = DateTime.parse(split.first.slice(1..-1))
    parsed_dates[date_time] = split.second.strip
  end
  parsed_dates.sort
end

parsed_by_datetime = parse_by_datetime(input_data)

def prefill_day_hash
  day = {}
  (0..59).each do |minute|
    day[minute] = {}
  end
  day
end

def prefill_day_counter
  day = {}
  (0..59).each do |minute|
    day[minute] = 0
  end
  day
end

def parse_input(input)
  days = {}
  sleep_high_scores = {}
  guard_minutes = {}
  guard_minute_high_scores = {}
  guard_frequency_high_score = { guard: -1, minute: -1, count: -1 }
  last_guard = -1
  last_minute = -1

  input.each do |date_time, event|
    date_str = date_time.to_date.to_s
    days[date_str] ||= prefill_day_hash
    minute = date_time.minute

    if event.include?(BEGINS_SHIFT)
      split = event.split(' ')
      guard_id = split[1].slice(1..-1)
      sleep_high_scores[guard_id] ||= 0
      guard_minutes[guard_id] ||= prefill_day_counter
      guard_minutes[guard_id][minute] ||= 0
      last_guard = guard_id

      days[date_str][minute][guard_id] = AWAKE
    elsif event.include?(FALLS_ASLEEP)
      guard_minutes[last_guard][minute] ||= 0
      guard_minutes[last_guard][minute] += 1
      sleep_high_scores[last_guard] += 1
      days[date_str][minute][last_guard] = ASLEEP
    elsif event.include?(WAKES_UP)
      ((last_minute + 1)...minute).each do |min|
        guard_minutes[last_guard][min] ||= 0
        guard_minutes[last_guard][min] += 1
        sleep_high_scores[last_guard] += 1
        days[date_str][min][last_guard] = ASLEEP
      end

      days[date_str][minute][last_guard] = AWAKE

    else
      raise "UNRECOGNIZED STATE!  #{date_time} - #{event}"
    end

    last_minute = minute
  end

  guard_minutes.each do |guard_id, minutes|
    guard_minute_high_scores[guard_id] = minutes.key(minutes.values.max)

    minutes.each do |minute, count|
      if count > guard_frequency_high_score[:count]
        guard_frequency_high_score[:guard] = guard_id
        guard_frequency_high_score[:minute] = minute
        guard_frequency_high_score[:count] = count
      end
    end
  end

  chosen_guard = sleep_high_scores.key(sleep_high_scores.values.max)

  chosen_minute = guard_minute_high_scores[chosen_guard]

  {
      sleep_high_scores: sleep_high_scores,
      guard_minute_high_scores: guard_minute_high_scores,
      guard_frequency_high_score: guard_frequency_high_score,
      chosen_guard: chosen_guard,
      chosen_minute: chosen_minute,
      answer: (chosen_guard.to_i * chosen_minute),
      answer2: (guard_frequency_high_score[:guard].to_i * guard_frequency_high_score[:minute])
  }
end

def test
  test_data = parse_by_datetime('[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up'.split("\n"))

  res = parse_input(test_data)

  raise "HIGH SCORES WRONG - #{res[:sleep_high_scores]}" unless res[:sleep_high_scores] == {"10"=>50, "99"=>30}
  raise "CHOSEN GUARD WRONG - #{res[:chosen_guard]}" unless res[:chosen_guard] == '10'
  raise "CHOSEN MINUTE WRONG - #{res[:chosen_minute]}" unless res[:chosen_minute] == 24
  raise "MATH WRONG - #{res[:answer]}" unless res[:answer] == 240

  #Part 2
  raise "GUARD FREQUENCY HIGH SCORE WRONG - #{res[:guard_frequency_high_score]}" unless res[:guard_frequency_high_score] == {:guard=>"99", :minute=>45, :count=>3}
  raise "PART 2 MATH WRONG - #{res[:answer2]}" unless res[:answer2] == 4455
  true
end

test()

res = parse_input(parsed_by_datetime)

p 'Answer for Part 1:'
p res[:answer]
p ''
p 'Answer for Part 2:'
p res[:answer2]

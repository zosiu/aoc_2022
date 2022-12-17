# frozen_string_literal: true

require_relative 'helper'

# ####
def shape_1(bottom, left)
  [[left, bottom], [left + 1, bottom], [left + 2, bottom], [left + 3, bottom]]
end

# .#.
# ###
# .#.
def shape_2(bottom, left)
  [[left + 1, bottom + 2],
   [left, bottom + 1], [left + 1, bottom + 1], [left + 2, bottom + 1],
   [left + 1, bottom]]
end

# ..#
# ..#
# ###
def shape_3(bottom, left)
  [[left + 2, bottom + 2],
   [left + 2, bottom + 1],
   [left, bottom], [left + 1, bottom], [left + 2, bottom]]
end

# #
# #
# #
# #
def shape_4(bottom, left)
  [[left, bottom + 3],
   [left, bottom + 2],
   [left, bottom + 1],
   [left, bottom]]
end

# ##
# ##
def shape_5(bottom, left)
  [[left, bottom + 1], [left + 1, bottom + 1],
   [left, bottom], [left + 1, bottom]]
end

def empty_cave(width)
  cave = Hash.new do |hsh, k|
    hsh[k] = '|' + ('.' * width) + '|'
  end
  cave[-1] = '+' + ('-' * width) + '+'

  cave
end

def highest_rock_in_cave(cave)
  cave.keys.select { |k| cave[k].include?('#') }.max || -1
end

def drop_rock(cave, shapes, jets)
  rock_bottom = highest_rock_in_cave(cave) + 3 + 1
  rock_left = 2 + 1
  rock_shape = shapes.next

  settled = false
  jets_used = 0

  until settled
    case jets.next
    when '<'
      rock_left -= 1 unless send(rock_shape, rock_bottom, rock_left - 1).any? { |(x, y)| cave[y][x] != '.' }
    when '>'
      rock_left += 1 unless send(rock_shape, rock_bottom, rock_left + 1).any? { |(x, y)| cave[y][x] != '.' }
    else
      raise 'WTF'
    end

    jets_used += 1
    if send(rock_shape, rock_bottom - 1, rock_left).any? { |(x, y)| cave[y][x] != '.' }
      settled = true
    else
      rock_bottom -= 1
    end
  end

  send(rock_shape, rock_bottom, rock_left).each { |(x, y)| cave[y][x] = '#' }

  jets_used
end

def cave_fingerprint(cave, fp_height)
  top = highest_rock_in_cave(cave)
  top.downto(top - fp_height).map { |i| cave[i] }.join("\n")
end

def cave_info(cave_width, shapes, jets)
  cave = empty_cave(cave_width)
  shapes_cycle = shapes.cycle
  jets_cycle = jets.cycle

  stats = {}
  states = {}
  jets_used_total = 0
  repeat_start = -1
  repeat_end = -1

  n = 0
  loop do
    jets_used = drop_rock(cave, shapes_cycle, jets_cycle)
    jets_used_total += jets_used
    jets_used_total %= jets.count if jets_used_total > jets.count

    top = highest_rock_in_cave(cave)
    stats[n] = [top, top - ((stats[n - 1] || []).first || 0)]

    state = { fp: cave_fingerprint(cave, 42), next_shape: shapes_cycle.peek, jets_used: jets_used_total }
    states[n] = state

    if states.values.count(state) > 1
      repeat_start, repeat_end = states.keys.select { |k| states[k] == state }
      break
    end

    n += 1
  end

  [repeat_start, repeat_end, stats.transform_values(&:last)]
end

def cave_height(num_rocks, cave_info)
  repeat_start, repeat_end, height_increases = cave_info

  if num_rocks > repeat_end
    repeat_sum = (repeat_start...repeat_end).sum { |i| height_increases[i] }
    corrected_num = num_rocks - repeat_start
    (0...repeat_start).sum { |i| height_increases[i] } +
      (corrected_num / (repeat_end - repeat_start)) * repeat_sum +
      (0...(corrected_num % (repeat_end - repeat_start))).sum { |i| height_increases[repeat_start + i] }
  else
    (0...num_rocks).sum { |i| height_increases[i] }
  end
end

# ---

shapes = %i[shape_1 shape_2 shape_3 shape_4 shape_5]
jets = input('17').chars
info = cave_info(7, shapes, jets)

puts cave_height(2022, info) + 1
puts cave_height(1_000_000_000_000, info) + 1

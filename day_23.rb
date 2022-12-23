# frozen_string_literal: true

require_relative 'helper'
require 'set'

def num_of_empty_ground_tiles(elves)
  min_x, max_x = elves.map(&:first).minmax
  min_y, max_y = elves.map(&:last).minmax

  (min_y..max_y).sum do |y|
    (min_x..max_x).sum do |x|
      elves.include?([x, y]) ? 0 : 1
    end
  end
end

def direction_diffs
  {
    N: [0, -1],
    S: [0, 1],
    W: [-1, 0],
    E: [1, 0],
    NE: [1, -1],
    NW: [-1, -1],
    SE: [1, 1],
    SW: [-1, 1]
  }
end

def direction_preferences(round)
  prefs = [
    { consider: %i[N NE NW], move: :N },
    { consider: %i[S SE SW], move: :S },
    { consider: %i[W NW SW], move: :W },
    { consider: %i[E NE SE], move: :E }
  ]

  start = round % prefs.count
  prefs.count.times.map do |n|
    prefs[(start + n) % prefs.count]
  end
end

def spread_out(elves, round)
  all_proposed_moves = Hash.new(0)
  elf_proposals = elves.each_with_object({}) do |(ex, ey), res|
    if direction_diffs.values.none? { |(dx, dy)| elves.include?([ex + dx, ey + dy]) }
      res[[ex, ey]] = { plan: :stay, reason: :nobody_around }
      all_proposed_moves[[ex, ey]] += 1
    else
      proposal_made = false
      direction_preferences(round).each do |pref|
        # puts "checking #{pref[:consider].join(' ')}"
        next if pref[:consider].any? do |dir|
                  elves.include?([ex + direction_diffs[dir].first, ey + direction_diffs[dir].last])
                end

        mx = ex + direction_diffs[pref[:move]].first
        my = ey + direction_diffs[pref[:move]].last
        res[[ex, ey]] = { plan: :move, coord: [mx, my] }
        all_proposed_moves[[mx, my]] += 1
        proposal_made = true
        break
      end
      next if proposal_made

      res[[ex, ey]] = { plan: :stay, reason: :no_valid_proposal }
      all_proposed_moves[[ex, ey]] += 1
    end
  end

  elf_proposals.each_with_object(Set.new) do |(orig_coord, prop), res|
    res << if (prop[:plan] == :stay) || (all_proposed_moves[prop[:coord]] > 1)
             orig_coord
           else
             prop[:coord]
           end
  end
end

# ---

elves = input_lines('23').each_with_index.each_with_object(Set.new) do |(line, j), res|
  line.chars.each_with_index do |c, i|
    res << [i, j] if c == '#'
  end
end

round = 0
loop do
  prev_elves = elves
  elves = spread_out(elves, round)
  puts num_of_empty_ground_tiles(elves) if round == 10
  round += 1
  break if prev_elves == elves
end

puts round

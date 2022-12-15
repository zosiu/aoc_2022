# frozen_string_literal: true

require_relative 'helper'
require 'set'
require 'z3'

def abs(t)
  Z3::IfThenElse(t >= 0, t, -t)
end

def beacon_pos(input, upper_bound)
  solver = Z3::Solver.new
  x = Z3.Int('x')
  y = Z3.Int('y')

  solver.assert(x >= 0)
  solver.assert(y >= 0)
  solver.assert(x <= upper_bound)
  solver.assert(y <= upper_bound)

  input_lines(input).each do |line|
    line.scan(/Sensor at x=(-?\d\d*), y=(-?\d\d*): closest beacon is at x=(-?\d\d*), y=(-?\d\d*)/) do |sx, sy, bx, by|
      distance = (sx.to_i - bx.to_i).abs + (sy.to_i - by.to_i).abs
      solver.assert(abs(sx.to_i - x) + abs(sy.to_i - y) > distance)
    end
  end

  if solver.satisfiable?
    model = solver.model
    [model[x].to_i, model[y].to_i]
  end
end

def num_positions_where_there_cannot_be_a_beacon(input, selected_row)
  info = input_lines(input).each_with_object({ selected_row_ranges: [], b_s: Set.new }) do |line, res|
    line.scan(/Sensor at x=(-?\d\d*), y=(-?\d\d*): closest beacon is at x=(-?\d\d*), y=(-?\d\d*)/) do |sx, sy, bx, by|
      sx = sx.to_i
      sy = sy.to_i
      bx = bx.to_i
      by = by.to_i

      res[:b_s] << [sx, sy]
      res[:b_s] << [bx, by]

      beacon_range = (sx - bx).abs + (sy - by).abs
      selected_row_dist = (sy - selected_row).abs

      next if selected_row_dist > beacon_range

      dx = beacon_range - selected_row_dist
      res[:selected_row_ranges] << Range.new(sx - dx, sx + dx)
    end
  end

  covered = info[:selected_row_ranges].inject(Set.new) { |res, e| res | e }
  beacons_and_sensors_count = info[:b_s].count { |x, y| y == selected_row && covered.include?(x) }

  covered.count - beacons_and_sensors_count
end

puts num_positions_where_there_cannot_be_a_beacon('15', 2_000_000)

x, y = beacon_pos('15', 4_000_000)
puts x * 4_000_000 + y

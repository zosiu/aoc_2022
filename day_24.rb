# frozen_string_literal: true

require_relative 'helper'
require 'set'
require 'pairing_heap'

def blizzard_free?(pos, minutes, valley_map)
  return false unless valley_map[:valid_coords].include?(pos)

  bliz_x = Set.new
  bliz_y = Set.new
  px, py = pos

  valley_map[:blizzards][[py, '>']].each { |b| bliz_x << (b + minutes) % valley_map[:count_x] }
  valley_map[:blizzards][[py, '<']].each { |b| bliz_x << (b - minutes) % valley_map[:count_x] }
  valley_map[:blizzards][[px, 'v']].each { |b| bliz_y << (b + minutes) % valley_map[:count_y] }
  valley_map[:blizzards][[px, '^']].each { |b| bliz_y << (b - minutes) % valley_map[:count_y] }

  !bliz_x.include?(px) && !bliz_y.include?(py)
end

Prio = Struct.new(:pos, :goal) do
  def dist_from_goal
    gx, gy = goal
    x, y = pos
    (gx - x).abs + (gy - y).abs
  end

  def <=(other)
    dist_from_goal <= other.dist_from_goal
  end
end

def time_to_get_to(from, to, start_time, valley_map)
  to_check = PairingHeap::MinPriorityQueue.new
  to_check.push([from, start_time], Prio.new(from, to))

  visited = Set.new
  times = Hash.new(Float::INFINITY)

  until to_check.empty?
    curr_pos, curr_time = to_check.pop

    next if visited.include?([curr_pos, curr_time])

    visited << [curr_pos, curr_time]
    times[curr_pos] = [times[curr_pos], curr_time].min

    px, py = curr_pos
    gx, gy = to
    next if times[to] < curr_time + (gx - px).abs + (gy - py).abs

    cx, cy = curr_pos
    new_time = curr_time + 1
    [[1, 0], [-1, 0], [0, 1], [0, -1], [0, 0]].each do |(dx, dy)|
      new_pos = [cx + dx, cy + dy]
      next unless blizzard_free?(new_pos, new_time, valley_map)

      to_check.push([new_pos, new_time], Prio.new(new_pos, to))
    rescue ArgumentError
      # ¯\_(ツ)_/¯
    end
  end

  times[to]
end

lines = input_lines('24')
start = [lines.shift.index('.') - 1, -1]
goal = [lines.pop.index('.') - 1, lines.count]

valley_map =
  lines.each_with_index
       .each_with_object({ valid_coords: Set.new, blizzards: Hash.new { |hsh, k| hsh[k] = [] } }) do |(line, y), res|
    line.chars.each_with_index do |c, x|
      res[:valid_coords] << [x - 1, y] unless c == '#'
      res[:blizzards][[y, c]] << x - 1 if ['<', '>'].include?(c)
      res[:blizzards][[x - 1, c]] << y if ['^', 'v'].include?(c)
    end
  end

valley_map[:count_x] = valley_map[:valid_coords].map(&:first).max + 1
valley_map[:count_y] = valley_map[:valid_coords].map(&:last).max + 1
valley_map[:valid_coords] << start
valley_map[:valid_coords] << goal

start_to_goal = time_to_get_to(start, goal, 0, valley_map)
puts start_to_goal

back_to_start = time_to_get_to(goal, start, start_to_goal, valley_map)
back_to_goal = time_to_get_to(start, goal, back_to_start, valley_map)
puts back_to_goal

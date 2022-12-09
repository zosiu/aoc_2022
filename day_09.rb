# frozen_string_literal: true

require_relative 'helper'
require 'set'

Coord = Struct.new(:x, :y)

def move_head(dir, head_pos)
  case dir
  when :R
    head_pos.x += 1
  when :L
    head_pos.x -= 1
  when :U
    head_pos.y -= 1
  when :D
    head_pos.y += 1
  end
end

def follow_head(head_pos, tail_pos)
  return if ((head_pos.x - tail_pos.x).abs < 2) && ((head_pos.y - tail_pos.y).abs < 2)

  if tail_pos.x == head_pos.x + 2 && tail_pos.y == head_pos.y then tail_pos.x -= 1
  elsif tail_pos.x == head_pos.x - 2 && tail_pos.y == head_pos.y then tail_pos.x += 1
  elsif tail_pos.y == head_pos.y + 2 && tail_pos.x == head_pos.x then tail_pos.y -= 1
  elsif tail_pos.y == head_pos.y - 2 && tail_pos.x == head_pos.x then tail_pos.y += 1
  else
    sx, sy = [[1, 1], [1, -1], [-1, 1], [-1, -1]].min_by do |dx, dy|
      (head_pos.x - tail_pos.x - dx).abs + (head_pos.y - tail_pos.y - dy).abs
    end
    tail_pos.x += sx
    tail_pos.y += sy
  end
end

moves = input_lines('09').flat_map { |line| line.scan(/([RLUD]) (\d+\d*)/) }.map { |(dir, num)| [dir.to_sym, num.to_i] }
rope = Array.new(10) { Coord.new(0, 0) }

puts (moves.each_with_object([Set.new, Set.new]) do |(dir, num), (first_tail_route, last_trail_route)|
  num.times do
    move_head(dir, rope.first)
    rope.each_cons(2) { |head, tail| follow_head(head, tail) }
    first_tail_route << rope[1].dup
    last_trail_route << rope.last.dup
  end
end).map(&:count)

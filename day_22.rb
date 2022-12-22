# frozen_string_literal: true

require_relative 'helper'

def cube_size
  50
end

def start(map)
  map.each_with_object([]) do |(y, line), res|
    line.each { |x, c| res << [y, x] if c == :open }
  end.min
end

def facing_to_dyx(facing)
  case facing
  when 0 then [0, 1] # right
  when 1 then [1, 0] # down
  when 2 then [0, -1] # left
  when 3 then [-1, 0] # up
  end
end

#     _ _
#    |A|B|
#   _|C|
#  |D|E|
#  |F|
def cube_top_lefts
  {
    A: [1, cube_size + 1],
    B: [1, 2 * cube_size + 1],
    C: [cube_size + 1, cube_size + 1],
    D: [2 * cube_size + 1, 1],
    E: [2 * cube_size + 1, cube_size + 1],
    F: [3 * cube_size + 1, 1]
  }
end

def coord_to_side(coord)
  top_lefts = cube_top_lefts
  y, x = coord
  side, top_left = top_lefts.find do |_s, c|
    cy, cx = c
    y.between?(cy, cy + cube_size - 1) && x.between?(cx, cx + cube_size - 1)
  end
  cy, cx = top_left
  [side, [y - cy, x - cx]]
end

def step(coord, facing, map, wrap_mode: :normal)
  cy, cx = coord
  dy, dx = facing_to_dyx(facing)

  ny = cy + dy
  nx = cx + dx

  return [ny, nx, facing] if map.key?(ny) && map[ny].key?(nx)

  case wrap_mode
  when :cube
    side, rel_to_corner = coord_to_side(coord)
    rel_y, rel_x = rel_to_corner
    case side
    when :A
      case facing
      when 2
        d_y, d_x = cube_top_lefts[:D]
        [d_y + cube_size - 1 - rel_y, d_x, 0]
      when 3
        f_y, f_x = cube_top_lefts[:F]
        [f_y + rel_x, f_x, 0]
      end
    when :B
      case facing
      when 0
        e_y, e_x = cube_top_lefts[:E]
        [e_y + cube_size - 1 - rel_y, e_x + cube_size - 1, 2]
      when 1
        c_y, c_x = cube_top_lefts[:C]
        [c_y + rel_x, c_x + cube_size - 1, 2]
      when 3
        f_y, f_x = cube_top_lefts[:F]
        [f_y + cube_size - 1, f_x + rel_x, 3]
      end
    when :C
      case facing
      when 0
        b_y, b_x = cube_top_lefts[:B]
        [b_y + cube_size - 1, b_x + rel_y, 3]
      when 2
        d_y, d_x = cube_top_lefts[:D]
        [d_y, d_x + rel_y, 1]
      end
    when :D
      case facing
      when 2
        a_y, a_x = cube_top_lefts[:A]
        [a_y + cube_size - 1 - rel_y, a_x, 0]
      when 3
        c_y, c_x = cube_top_lefts[:C]
        [c_y + rel_x, c_x, 0]
      end
    when :E
      case facing
      when 0
        b_y, b_x = cube_top_lefts[:B]
        [b_y + cube_size - 1 - rel_y, b_x + cube_size - 1, 2]
      when 1
        f_y, f_x = cube_top_lefts[:F]
        [f_y + rel_x, f_x + cube_size - 1, 2]
      end
    when :F
      case facing
      when 0
        e_y, e_x = cube_top_lefts[:E]
        [e_y + cube_size - 1, e_x + rel_y, 3]
      when 1
        b_y, b_x = cube_top_lefts[:B]
        [b_y, b_x + rel_x, 1]
      when 2
        a_y, a_x = cube_top_lefts[:A]
        [a_y, a_x + rel_y, 1]
      end
    end
  when :normal
    case facing
    when 0 then [cy, map[cy].keys.min, facing] # right
    when 1 then [map.keys.select { |y| map[y].key?(cx) }.min, cx, facing] # down
    when 2 then [cy, map[cy].keys.max, facing] # left
    when 3 then [map.keys.select { |y| map[y].key?(cx) }.max, cx, facing] # up
    end
  end
end

def follow_instructions(map, instructions, wrap_mode: :normal)
  current_coord = start(map)
  facing = 0

  instructions.each do |inst|
    case inst
    when :turn_r
      facing = (facing + 1) % 4
    when :turn_l
      facing = (facing - 1) % 4
    else
      inst.times do
        ny, nx, nf = step(current_coord, facing, map, wrap_mode: wrap_mode)
        break if map[ny][nx] == :solid

        facing = nf
        current_coord = [ny, nx]
      end
    end
  end

  fy, fx = current_coord
  1000 * fy + 4 * fx + facing
end

# --

raw_map, instructions = input_batches('22')
instructions = instructions.first.split(/([RL])/).map do |elem|
  case elem
  when 'R' then :turn_r
  when 'L' then :turn_l
  else elem.to_i
  end
end

map = raw_map.each_with_index.each_with_object(Hash.new { |hsh, k| hsh[k] = {} }) do |(line, y), res|
  line.chars.each_with_index do |c, x|
    case c
    when '.' then res[y + 1][x + 1] = :open
    when '#' then res[y + 1][x + 1] = :solid
    end
  end
end

puts follow_instructions(map, instructions)

puts follow_instructions(map, instructions, wrap_mode: :cube)

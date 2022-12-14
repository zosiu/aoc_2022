# frozen_string_literal: true

require_relative 'helper'

def max_rock_depth(scan)
  scan.select { |_k, v| v == :rock }.map(&:first).map(&:last).max
end

def read_scan(scan, x, y, max_rock_y, infinite_ground: false)
  return scan[[x, y]] unless infinite_ground

  y == max_rock_y + 2 ? :rock : scan[[x, y]]
end

def sand_coords(scan, sand_start, max_rock_y, infinite_ground: false)
  sand = sand_start
  settled = false
  falling_into_the_abyss = sand.last > max_rock_y

  until settled || falling_into_the_abyss
    x, y = sand
    below_free = read_scan(scan, x, y + 1, max_rock_y, infinite_ground: infinite_ground) == :air
    below_diag_left_free = read_scan(scan, x - 1, y + 1, max_rock_y, infinite_ground: infinite_ground) == :air
    below_diag_right_free = read_scan(scan, x + 1, y + 1, max_rock_y, infinite_ground: infinite_ground) == :air

    if below_free
      sand = [x, y + 1]
    elsif below_diag_left_free
      sand = [x - 1, y + 1]
    elsif below_diag_right_free
      sand = [x + 1, y + 1]
    else
      settled = true
    end

    falling_into_the_abyss = sand.last > max_rock_y
  end

  { sand_coords: sand, settled: settled, falling_into_the_abyss: falling_into_the_abyss }
end

def simulate_sand(input, infinite_ground: false)
  scan = input_lines(input).each_with_object(Hash.new(:air)) do |line, res|
    coords = line.split(/\s*->\s*/).map { |cp| cp.split(/\s*,\s*/).map(&:to_i) }
    coords.each_cons(2) do |(x1, y1), (x2, y2)|
      Range.new(*[y1, y2].sort).each { |y| res[[x1, y]] = :rock } if x1 == x2
      Range.new(*[x1, x2].sort).each { |x| res[[x, y1]] = :rock } if y1 == y2
    end
  end

  sand_start = [500, 0]
  scan[sand_start] = :sand_start
  max_rock_y = max_rock_depth(scan)

  loop do
    new_sand = sand_coords(scan, sand_start, max_rock_y, infinite_ground: infinite_ground)
    break if !infinite_ground && new_sand[:falling_into_the_abyss]

    scan[new_sand[:sand_coords]] = :sand
    break if infinite_ground && (new_sand[:sand_coords] == sand_start)
  end

  scan.values.count(:sand)
end

puts simulate_sand('14')
puts simulate_sand('14', infinite_ground: true)

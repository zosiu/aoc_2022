# frozen_string_literal: true

require_relative 'helper'
require 'set'

def surface_area(cubes)
  cube_sides = {}
  cubes.each do |center|
    sides = Set.new(%i[x_minus x_plus y_minus y_plus z_minus z_plus])
    x1, y1, z1 = center
    cube_sides.each do |other_center, other_sides|
      x2, y2, z2 = other_center

      if x1 - 1 == x2 && y1 == y2 && z1 == z2
        sides.delete(:x_minus)
        other_sides.delete(:x_plus)
      end

      if x1 + 1 == x2 && y1 == y2 && z1 == z2
        sides.delete(:x_plus)
        other_sides.delete(:x_minus)
      end

      if y1 - 1 == y2 && x1 == x2 && z1 == z2
        sides.delete(:y_minus)
        other_sides.delete(:y_plus)
      end

      if y1 + 1 == y2 && x1 == x2 && z1 == z2
        sides.delete(:y_plus)
        other_sides.delete(:y_minus)
      end

      if z1 - 1 == z2 && x1 == x2 && y1 == y2
        sides.delete(:z_minus)
        other_sides.delete(:z_plus)
      end

      if z1 + 1 == z2 && x1 == x2 && y1 == y2
        sides.delete(:z_plus)
        other_sides.delete(:z_minus)
      end
    end

    cube_sides[center] = sides
  end

  cube_sides.values.sum(&:count)
end

def unreachable_cubes(cubes)
  solid_cubes = Set.new(cubes)

  min_x, max_x = cubes.map { |c| c[0] }.minmax
  min_y, max_y = cubes.map { |c| c[1] }.minmax
  min_z, max_z = cubes.map { |c| c[2] }.minmax

  inside_cubes = []
  (min_x..max_x).each do |x|
    (min_y..max_y).each do |y|
      (min_z..max_z).each do |z|
        inside_cubes << [x, y, z] unless solid_cubes.include?([x, y, z])
      end
    end
  end

  to_check = inside_cubes.select do |(x, y, z)|
    x == min_x || x == max_x ||
      y == min_y || y == max_y ||
      z == min_z || z == max_z
  end
  reachable = Set.new(to_check)
  unreachable = Set.new

  until to_check.empty?
    x1, y1, z1 = to_check.shift

    neighbors = [[x1 - 1, y1, z1],
                 [x1 + 1, y1, z1],
                 [x1, y1 - 1, z1],
                 [x1, y1 + 1, z1],
                 [x1, y1, z1 - 1],
                 [x1, y1, z1 + 1]]

    if neighbors.all? { |n| unreachable.include?(n) || solid_cubes.include?(n) }
      unreachable << [x1, y1, z1]
    elsif neighbors.any? do |(x2, y2, z2)|
            x2 <= min_x || x2 >= max_x ||
            y2 <= min_y || y2 >= max_y ||
            z2 <= min_z || z2 >= max_z ||
            reachable.include?([x2, y2, z2])
          end
      reachable << [x1, y1, z1]
    else
      to_check << [x1, y1, z1] unless to_check.include?([x1, y1, z1])
    end

    neighbors.each do |(x2, y2, z2)|
      next if x2 <= min_x || x2 >= max_x || y2 <= min_y || y2 >= max_y || z2 <= min_z || z2 >= max_z
      next if solid_cubes.include?([x2, y2, z2])
      next if reachable.include?([x2, y2, z2])
      next if unreachable.include?([x2, y2, z2])

      to_check << [x2, y2, z2] unless to_check.include?([x2, y2, z2])
    end
  end

  inside_cubes.each do |(x, y, z)|
    unreachable << [x, y, z] unless reachable.include?([x, y, z])
  end

  unreachable.to_a
end

# ---

cubes = input_lines('18').map { |l| l.split(/\s*,\s*/).map(&:to_i) }

outside_surface_area = surface_area(cubes)
puts outside_surface_area

puts outside_surface_area - surface_area(unreachable_cubes(cubes))

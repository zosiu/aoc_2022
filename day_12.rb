# frozen_string_literal: true

require_relative 'helper'

def distances_to_goal(goal, elevation_map)
  distances = Hash.new(Float::INFINITY)
  distances[goal] = 0
  to_check = [goal]

  until to_check.empty?
    cx, cy = to_check.shift
    [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |(dx, dy)|
      neighbor = [cx + dx, cy + dy]
      next unless elevation_map[neighbor] &&
                  (elevation_map[neighbor].ord >= elevation_map[[cx, cy]].ord - 1)

      dist = distances[[cx, cy]] + 1
      if dist <= distances[neighbor]
        distances[neighbor] = dist
        to_check << neighbor unless to_check.include?(neighbor)
      end
    end
  end

  distances
end

info = input_lines('12').each_with_index.each_with_object({ elevation_map: {} }) do |(line, j), ret|
  line.chars.each_with_index do |char, i|
    case char
    when 'S'
      ret[:elevation_map][[i, j]] = 'a'
      ret[:start] = [i, j]
    when 'E'
      ret[:elevation_map][[i, j]] = 'z'
      ret[:goal] = [i, j]
    else
      ret[:elevation_map][[i, j]] = char
    end
  end
end

distances = distances_to_goal(info[:goal], info[:elevation_map])

puts distances[info[:start]]
puts info[:elevation_map].each_key.select { |k| info[:elevation_map][k] == 'a' }
                         .map { |start| distances[start] }
                         .min

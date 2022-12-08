# frozen_string_literal: true

require_relative 'helper'
require 'set'

def given_tree_is_taller(tree)
  ->(other_tree) { other_tree < tree }
end

def scenic_score(i, j, grid)
  tree = grid[j][i]
  left = 0
  right = 0
  up = 0
  down = 0

  (i - 1).downto(0) do |oi|
    left += 1
    break unless given_tree_is_taller(tree).call(grid[j][oi])
  end

  (i + 1).upto(grid[j].count - 1) do |oi|
    right += 1
    break unless given_tree_is_taller(tree).call(grid[j][oi])
  end

  (j - 1).downto(0) do |oj|
    up += 1
    break unless given_tree_is_taller(tree).call(grid[oj][i])
  end

  (j + 1).upto(grid.count - 1) do |oj|
    down += 1
    break unless given_tree_is_taller(tree).call(grid[oj][i])
  end

  [up, left, down, right].inject(:*)
end

grid = input_lines('08').map { |line| line.chars.map(&:to_i) }

visible_trees = grid.count.times.each_with_object(Set.new) do |j, res|
  grid.first.count.times do |i|
    tree = grid[j][i]
    col = grid.map { |row| row[i] }

    next unless (i.zero? || j.zero? || (i == grid[j].count - 1) || (j == grid.count - 1)) || # on edge
                grid[j][0...i].all?(given_tree_is_taller(tree)) || # visible from the left
                grid[j][i + 1..-1].all?(given_tree_is_taller(tree)) || # visible from the right
                col[0...j].all?(given_tree_is_taller(tree)) || # visible from up
                col[j + 1..-1].all?(given_tree_is_taller(tree)) # visible from down

    res << [i, j]
  end
end

puts visible_trees.count
puts visible_trees.map { |(i, j)| scenic_score(i, j, grid) }.max

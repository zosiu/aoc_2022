# frozen_string_literal: true

require_relative 'helper'

def mix(nums_with_index)
  nums_with_index.count.times do |num_index|
    i = nums_with_index.find_index { |_n, orig_index| orig_index == num_index }
    num, orig_i = nums_with_index.delete_at(i)
    nums_with_index.insert((i + num) % nums_with_index.count, [num, orig_i])
  end
end

def sum_at_indices_after_0(indices, nums_with_index)
  start = nums_with_index.find_index { |n, _i| n.zero? }
  indices.sum { |i| nums_with_index[(start + i) % nums_with_index.count].first }
end

numbers = input_lines('20').map(&:to_i)

nums_with_index = numbers.each_with_index.to_a
mix(nums_with_index)
puts sum_at_indices_after_0([1000, 2000, 3000], nums_with_index)

decrypted_nums_with_index = numbers.each_with_index.map { |n, i| [811_589_153 * n, i] }
10.times { mix(decrypted_nums_with_index) }
puts sum_at_indices_after_0([1000, 2000, 3000], decrypted_nums_with_index)

# frozen_string_literal: true

require_relative 'helper'

ration_packs = input_batches('01')
top_three_calory_packs = ration_packs.map { |batch| batch.map(&:to_i).sum }.max(3)

puts top_three_calory_packs.max
puts top_three_calory_packs.sum

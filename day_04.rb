# frozen_string_literal: true

require_relative 'helper'

assignments = input_lines('04').map do |str|
  str.scan(/\d+/).map(&:to_i).each_slice(2).map do |bounds|
    Range.new(*bounds)
  end
end

puts assignments.count { |(r1, r2)| r1.cover?(r2) || r2.cover?(r1) }
puts assignments.count { |(r1, r2)| r1.cover?(r2.first) || r2.cover?(r1.first) }

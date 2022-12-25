# frozen_string_literal: true

require_relative 'helper'
require 'z3'

def dec_to_snafu(num)
  num.to_s.chars.reverse.inject([0, 1]) do |(sum, pow), c|
    sum += pow * { '2' => 2,
                   '1' => 1,
                   '0' => 0,
                   '-' => -1,
                   '=' => -2 }[c]
    pow *= 5
    [sum, pow]
  end.first
end

def snafu_to_dec(num, max_digits = 50)
  pow_table = max_digits.times.each_with_object([1]) { |_i, res| res << res.last * 5 }
  solver = Z3::Solver.new

  digits = max_digits.times.each_with_object([]) do |n, res|
    digit = Z3.Int("digit_#{n}")
    solver.assert(digit >= -2)
    solver.assert(digit <= 2)
    res << digit
  end

  solver.assert(digits.each_with_index.sum { |d, i| pow_table[i] * d } == num)

  if solver.satisfiable?
    model = solver.model
    conv_digits = max_digits.times.map { |n| model[digits[n]].to_i }.reverse
    conv_digits[conv_digits.index { |x| !x.zero? }..-1].map do |d|
      { 2 => '2',
        1 => '1',
        0 => '0',
        -1 => '-',
        -2 => '=' }[d]
    end.join
  end
end

# -

puts snafu_to_dec(input_lines('25').sum { |line| dec_to_snafu(line) })

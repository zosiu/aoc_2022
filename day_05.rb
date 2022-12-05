# frozen_string_literal: true

require_relative 'helper'

def unload_result(instructions, crane_model: 9000)
  crates = [
    %w[],
    %w[Q F M R L W C V],
    %w[D Q L],
    %w[P S R G W C N B],
    %w[L C D H B Q G],
    %w[V G L F Z S],
    %w[D G N P],
    %w[D Z P V F C W],
    %w[C P D M S],
    %w[Z N W T V M P C]
  ]

  instructions.each do |(num_crates, from_stack, to_stack)|
    to_move = crates[from_stack].pop(num_crates)
    to_move.reverse! unless crane_model == 9001
    crates[to_stack].push(*to_move)
  end

  crates.map(&:last).join
end

instructions = input_lines('05').map { |str| str.scan(/\d+/).map(&:to_i) }

puts unload_result(instructions)
puts unload_result(instructions, crane_model: 9001)

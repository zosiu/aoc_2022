# frozen_string_literal: true

require_relative 'helper'

ship, instructions_str = input('05').split(/\n\n/)
instructions = instructions_str.lines.map { |str| str.scan(/\d+/) }

def parse_crates(str)
  crate_ids, *crates_lines = str.lines.reverse
  crates_info = []
  crate_ids.scan(/(\d+)/) do
    md = Regexp.last_match
    crates_info << [md.captures.first, md.offset(0).first]
  end
  [crates_info.map(&:first),
   crates_lines.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |line, res|
     crates_info.each do |(crate_id, crate_index)|
       res[crate_id] << line[crate_index]
     end
   end.transform_values { |v| v.reject { |s| s.to_s.strip.empty? } }]
end

def unload_result(ship, instructions, crane_model: 9000)
  crate_ids, crates = parse_crates(ship)
  instructions.each do |(num_crates, from_stack, to_stack)|
    to_move = crates[from_stack].pop(num_crates.to_i)
    to_move.reverse! unless crane_model == 9001
    crates[to_stack].push(*to_move)
  end

  crate_ids.map { |id| crates[id].last }.join
end

puts unload_result(ship, instructions)
puts unload_result(ship, instructions, crane_model: 9001)

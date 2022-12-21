# frozen_string_literal: true

require_relative 'helper'
require 'z3'

def solve_normally(known_vars, unknown_vars, key)
  to_check = unknown_vars.keys

  until to_check.empty?
    curr_monkey = to_check.shift
    rec = unknown_vars[curr_monkey]

    if [rec[:lhs], rec[:rhs]].all? { |m| known_vars.key?(m) }
      known_vars[curr_monkey] = known_vars[rec[:lhs]].send(rec[:op], known_vars[rec[:rhs]])
    else
      to_check << curr_monkey
    end
  end

  known_vars[key]
end

def solve_eql(known_vars, unknown_vars, eql_key, shout_key)
  known_vars.delete(shout_key)

  solver = Z3::Solver.new
  vars = ([shout_key] + unknown_vars.keys).each_with_object({}) do |monkey, hsh|
    hsh[monkey] = Z3.Int(monkey)
  end

  unknown_vars.each do |monkey, record|
    lhs = known_vars[record[:lhs]] || vars[record[:lhs]]
    rhs = known_vars[record[:rhs]] || vars[record[:rhs]]

    if monkey == eql_key
      solver.assert(lhs == rhs)
    else
      solver.assert(vars[monkey] == lhs.send(record[:op], rhs))
    end
  end

  solver.model[vars[shout_key]] if solver.satisfiable?
end

# --

data = input_lines('21').sort_by(&:length).each_with_object({ known_vars: {}, unknown_vars: {} }) do |line, res|
  case line
  when /(?<monkey>\w{4}): (?<number>\d+)/
    res[:known_vars][Regexp.last_match[:monkey]] = Regexp.last_match[:number].to_i
  when %r{(?<monkey1>\w{4}): (?<monkey2>\w{4}) (?<op>[/*+-]) (?<monkey3>\w{4})}
    res[:unknown_vars][Regexp.last_match[:monkey1]] =
      { lhs: Regexp.last_match[:monkey2], rhs: Regexp.last_match[:monkey3], op: Regexp.last_match[:op].to_sym }
  end
end

puts solve_normally(data[:known_vars].dup, data[:unknown_vars].dup, 'root')
puts solve_eql(data[:known_vars].dup, data[:unknown_vars].dup, 'root', 'humn')

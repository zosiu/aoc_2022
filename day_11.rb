# frozen_string_literal: true

require_relative 'helper'

def round(monkeys, mega_worried: false)
  monkeys.keys.sort.each do |id|
    monkey = monkeys[id]
    monkey[:inspected_items_count] += monkey[:starting_items].count
    until monkey[:starting_items].empty?
      worry_level = monkey[:starting_items].shift

      if mega_worried
        unless worry_level.is_a?(Hash)
          worry_level = monkeys.values.each_with_object({}) do |m, hsh|
            hsh[m[:id]] = { test: m[:test], worry_level: worry_level % m[:test] }
          end
        end
        worry_level.transform_values! do |v|
          { test: v[:test],
            worry_level: v[:worry_level].send(monkey[:opreration][:method], monkey[:opreration][:arg]) % v[:test] }
        end
        to_check = worry_level[monkey[:id]][:worry_level]
      else
        worry_level = worry_level.send(monkey[:opreration][:method], monkey[:opreration][:arg])
        worry_level /= 3
        to_check = worry_level % monkey[:test]
      end

      monkey_to = monkeys[monkey[to_check.zero? ? :test_true : :test_false]]
      monkey_to[:starting_items] << worry_level
    end
  end
end

def observe_monkeys(input_name, num_rounds:, mega_worried: false)
  monkeys = input_batches(input_name).each_with_object({}) do |lines, info|
    monkey_row, starting_items_row, opreration_row, test_row, test_true_row, test_false_row = lines
    monkey_id = monkey_row.match(/(\d\d*)/).captures.first.to_i
    info[monkey_id] = { id: monkey_id }
    info[monkey_id][:starting_items] =
      starting_items_row.match(/Starting items: (.*)/).captures.first.split(/,\s*/).map(&:to_i)
    md = opreration_row.match(/Operation: new = old (.) (.*)/)
    method = md.captures.first.to_sym
    arg = md.captures.last
    info[monkey_id][:opreration] = {
      method: arg == 'old' ? :pow : method.to_sym,
      arg: arg == 'old' ? 2 : arg.to_i
    }
    info[monkey_id][:test] = test_row.match(/(\d\d*)/).captures.first.to_i
    info[monkey_id][:test_true] = test_true_row.match(/(\d\d*)/).captures.first.to_i
    info[monkey_id][:test_false] = test_false_row.match(/(\d\d*)/).captures.first.to_i
    info[monkey_id][:inspected_items_count] = 0
  end

  num_rounds.times { round(monkeys, mega_worried: mega_worried) }
  monkeys.values.map { |monkey| monkey[:inspected_items_count] }.sort.last(2).inject(:*)
end

puts observe_monkeys('11', num_rounds: 20)
puts observe_monkeys('11', num_rounds: 10_000, mega_worried: true)

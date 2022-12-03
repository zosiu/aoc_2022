# frozen_string_literal: true

require_relative 'helper'

rucksacks = input_lines('03')

def priority(item)
  item.downcase.ord - 'a'.ord + 1 + (item == item.upcase ? ('z'.ord - 'a'.ord + 1) : 0)
end

def common_item(list)
  list.inject(&:&).first
end

puts rucksacks.map { |rucksack| rucksack.partition(/.{#{rucksack.size / 2}}/)[1, 2].map(&:chars) }
              .map { |items| common_item(items) }
              .sum { |item| priority(item) }

puts rucksacks.map(&:chars)
              .each_slice(3)
              .map { |items| common_item(items) }
              .sum { |item| priority(item) }

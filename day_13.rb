# frozen_string_literal: true

require_relative 'helper'
require 'json'

class Array
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end

def compare_packets(lhs, rhs)
  return lhs <=> rhs if [lhs, rhs].all? { |param| param.is_a?(Numeric) }
  return compare_packets(Array.wrap(lhs), Array.wrap(rhs)) unless [lhs, rhs].all? { |param| param.is_a?(Array) }

  res = 0
  lhs.each_with_index do |item, i|
    return 1 if rhs[i].nil?

    res = compare_packets(item, rhs[i])
    return res unless res.zero?
  end

  rhs.count > lhs.count ? -1 : res
end

packet_pairs = input_batches('13').map { |b| b.map { |l| JSON.parse(l) } }
puts packet_pairs.each_with_index
                 .map { |p, i| compare_packets(*p) == -1 ? i + 1 : 0 }
                 .sum

divider_packets = [[[2]], [[6]]]
all_packets = packet_pairs.flatten(1) + divider_packets
packets_sorted = all_packets.sort { |lhs, rhs| compare_packets(lhs, rhs) }
puts divider_packets.map { |packet| packets_sorted.find_index(packet) + 1 }.inject(:*)

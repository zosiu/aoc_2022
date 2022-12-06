# frozen_string_literal: true

require_relative 'helper'

def start_of_message_marker(buffer, packet_len)
  buffer.each_cons(packet_len).find_index { |packet| packet.uniq.count == packet_len } + packet_len
end

buffer = input('06').chars

puts start_of_message_marker(buffer, 4)
puts start_of_message_marker(buffer, 14)

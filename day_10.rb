# frozen_string_literal: true

require_relative 'helper'

class Device
  attr_reader :cycle_counter, :register_x, :sygnal_strenghts

  @@crt_rows = 6
  @@crt_cols = 40
  @@unlit_pixel = ' '
  @@lit_pixel = '█'

  def initialize
    @register_x = 1
    @cycle_counter = 1
    @sygnal_strenghts = []
    @pixel_position = 0
    @crt_row = 0
    @crt = Array.new(@@crt_rows) { @@unlit_pixel * @@crt_cols }
  end

  def noop(args: {}, num_cycles: 1)
    num_cycles.times { perform_single_cycle_instruction {} }
  end

  def addx(args:)
    noop(num_cycles: 1)
    perform_single_cycle_instruction { @register_x += args[:value] }
  end

  def crt
    @crt.join("\n")
  end

  private

  def record_sygnal_strength
    sygnal_strenghts[cycle_counter] = cycle_counter * register_x
  end

  def draw_on_screen
    return unless [-1, 0, 1].map { |offxet| @pixel_position + offxet }.any? { |px| px == @register_x }

    @crt[@crt_row][@pixel_position] = @@lit_pixel
  end

  def advance_pixel_pos
    @pixel_position += 1
    return unless @pixel_position == @@crt_cols

    @pixel_position = 0
    @crt_row += 1
  end

  def perform_single_cycle_instruction
    draw_on_screen
    yield
    @cycle_counter += 1
    advance_pixel_pos
    record_sygnal_strength
  end
end

instructions = input_lines('10').map do |line|
  case line
  when /noop/ then { opcode: :noop, args: {} }
  when /addx (-?\d\d*)/ then { opcode: :addx, args: { value: Regexp.last_match.captures.first.to_i } }
  end
end

handheld = Device.new

instructions.each { |instruction| handheld.send(instruction[:opcode], args: instruction[:args]) }

puts [20, 60, 100, 140, 180, 220].sum { |cycle| handheld.sygnal_strenghts[cycle] }
puts handheld.crt

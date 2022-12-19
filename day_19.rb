# frozen_string_literal: true

require_relative 'helper'
require 'set'
require 'pairing_heap'

def tick(state)
  new_state = state.dup
  new_state[:time] -= 1
  %i[ore clay obsidian].each { |mat| new_state[mat] += new_state["#{mat}_robot".to_sym] }
  new_state
end

def robot_can_be_built?(state, robot, bp)
  bp[:costs][robot].all? { |mat, cost| state[mat] >= cost }
end

def more_robots_could_be_useful?(state, mat, bp)
  return true if mat == :geode

  current_mat = state[mat]
  current_mat_prod = state["#{mat}_robot".to_sym]
  time_remaining = state[:time]
  max_mat_needed = bp[:max_needed]["#{mat}_robot".to_sym]

  current_mat + current_mat_prod * time_remaining < time_remaining * max_mat_needed
end

def build_robot(state, robot, bp)
  new_state = state.dup
  bp[:costs][robot].each { |mat, cost| new_state[mat] -= cost }
  if robot == :geode_robot
    new_state[:geode] += new_state[:time]
  else
    new_state[robot] += 1
  end
  new_state
end

def possibilities(state, bp)
  return [] unless state[:time].positive?

  %i[geode obsidian clay ore].each_with_object([]) do |mat, res|
    next unless more_robots_could_be_useful?(state, mat, bp)

    robot = "#{mat}_robot".to_sym

    prev_state = state.dup
    curr_state = tick(prev_state)

    until robot_can_be_built?(prev_state, robot, bp) || curr_state[:time] <= 0
      prev_state = curr_state
      curr_state = tick(curr_state)
    end

    res << build_robot(curr_state, robot, bp) if robot_can_be_built?(prev_state, robot, bp)
  end
end

Prio = Struct.new(:r1, :r2, :r3, :t) do
  def <=(other)
    r1 >= other.r1 &&
      r2 >= other.r2 &&
      r3 >= other.r3 &&
      t <= other.t
  end
end

def priority(state)
  Prio.new(state[:geode], state[:obsidian], state[:clay], state[:time])
end

def max_geodes(bp, minutes)
  starting_state = {
    time: minutes,

    ore: 0,
    clay: 0,
    obsidian: 0,
    geode: 0,

    ore_robot: 1,
    clay_robot: 0,
    obsidian_robot: 0
  }

  most_geodes = 0
  to_check = PairingHeap::MinPriorityQueue.new
  to_check.push(starting_state, priority(starting_state))
  checked = Set.new

  until to_check.empty?
    state = to_check.pop
    next if checked.include?(state)

    checked << state

    current_geodes = state[:geode]
    most_geodes = [current_geodes, most_geodes].max
    most_possible_future_geodes = state[:time] * (state[:time] - 1) / 2
    next if current_geodes + most_possible_future_geodes < most_geodes

    possibilities(state, bp).each do |next_state|
      pp [state, next_state] unless next_state.is_a?(Hash)
      to_check.push(next_state, priority(next_state)) unless checked.include?(next_state)
    rescue ArgumentError
      # ¯\_(ツ)_/¯
    end
  end

  most_geodes
end

blueprints = input_lines('19').map do |l|
  bp_id, ore_robot_ore_cost, clay_robot_ore_cost,
    obsidian_robot_ore_cost, obsidian_robot_clay_cost,
    geode_robot_ore_cost, geode_robot_obsidian_cost = l.scan(/\d+/).map(&:to_i)
  {
    id: bp_id,
    costs: {
      ore_robot: { ore: ore_robot_ore_cost },
      clay_robot: { ore: clay_robot_ore_cost },
      obsidian_robot: { ore: obsidian_robot_ore_cost, clay: obsidian_robot_clay_cost },
      geode_robot: { ore: geode_robot_ore_cost, obsidian: geode_robot_obsidian_cost }
    },
    max_needed: {
      ore_robot: [ore_robot_ore_cost, clay_robot_ore_cost, obsidian_robot_ore_cost, geode_robot_ore_cost].max,
      clay_robot: obsidian_robot_clay_cost,
      obsidian_robot: geode_robot_obsidian_cost
    }
  }
end

puts blueprints.sum { |bp| bp[:id] * max_geodes(bp, 24) }

puts blueprints.first(3).map { |bp| max_geodes(bp, 32) }.inject(:*)

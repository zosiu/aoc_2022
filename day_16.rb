# frozen_string_literal: true

require_relative 'helper'
require 'duplicate'
require 'set'

def minimum_distances_between_all_nodes(info)
  nodes = info.keys
  minimum_distances = nodes.each_with_object({}) do |node, res|
    res[node] = Hash.new(Float::INFINITY)
    res[node][node] = 0
    info[node][:connections].each do |connection|
      res[node][connection] = 1
    end
  end

  nodes.each do |k|
    nodes.each do |i|
      nodes.each do |j|
        if minimum_distances[i][j] > minimum_distances[i][k] + minimum_distances[k][j]
          minimum_distances[i][j] = minimum_distances[i][k] + minimum_distances[k][j]
        end
      end
    end
  end

  minimum_distances
end

def total_pressure(state, info, max_time = 30)
  state[:opened].inject(0) do |sum, (valve_name, time)|
    sum + info[valve_name][:flow_rate] * (max_time - time)
  end
end

def possible_states(state, info, distances, important_nodes, max_time = 30)
  current_node = state[:node]

  (important_nodes - state[:visited]).each_with_object([]) do |node, states|
    node_activation_time = state[:time] + distances[current_node][node] + 1
    next if node_activation_time >= max_time

    opened = duplicate(state[:opened])
    opened[node] = node_activation_time
    visited = state[:visited] | [node]
    new_state = { node: node, time: node_activation_time, opened: opened, visited: visited }
    new_state[:total_pressure] = total_pressure(new_state, info, max_time)

    states << new_state
  end
end

def max_total_pressure(max_time, important_nodes, info, minimum_distances, with_local_maximums: false)
  starting_state = { node: 'AA', time: 0, opened: {}, visited: Set.new }
  starting_state[:total_pressure] = total_pressure(starting_state, info)

  to_check = [starting_state]
  best_flows = Hash.new(0)
  best_flows_extended = Hash.new { |hsh, k| hsh[k] = Hash.new(0) }

  until to_check.empty?
    current_state = to_check.shift

    possible_states(current_state, info, minimum_distances, important_nodes, max_time).each do |next_state|
      if with_local_maximums
        next if best_flows_extended[next_state[:visited]][next_state[:time]] > next_state[:total_pressure]

        best_flows_extended[next_state[:visited]][next_state[:time]] = next_state[:total_pressure]
      else
        next if best_flows[next_state[:visited]] > next_state[:total_pressure]

        best_flows[next_state[:visited]] = next_state[:total_pressure]
      end

      to_check << next_state unless to_check.include?(next_state)
    end
  end

  with_local_maximums ? best_flows_extended : best_flows
end

# ---

info = input_lines('16').each_with_object({}) do |line, res|
  line.scan(/Valve (.*) has flow rate=(\d+\d*); tunnel(?:s?) lead(?:s?) to valve(?:s?) (.*)/) do |valve_name, flow_rate, other_valves|
    connections = other_valves.split(/\s*,\s*/)
    res[valve_name] = {
      flow_rate: flow_rate.to_i,
      connections: connections
    }
  end
end

minimum_distances = minimum_distances_between_all_nodes(info)
important_nodes = Set.new(info.keys.select { |valve_name| info[valve_name][:flow_rate].positive? })

pressures_at_30 = max_total_pressure(30, important_nodes, info, minimum_distances)
puts pressures_at_30.values.max

pressures_at_26 = max_total_pressure(26, important_nodes, info, minimum_distances, with_local_maximums: true)
puts pressures_at_26.keys.combination(2).map { |k1, k2|
  (k1 & k2).empty? ? pressures_at_26[k1].values.max + pressures_at_26[k2].values.max : 0
}.max

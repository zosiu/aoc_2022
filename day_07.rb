# frozen_string_literal: true

require_relative 'helper'

def nested_dirs(dir)
  [dir] + dir.dirs.values.map { |c| nested_dirs(c) }.flatten
end

def total_size(dir)
  dir.files.values.sum + dir.dirs.values.sum { |d| total_size(d) }
end

ElfDir = Struct.new(:parent, :name, :dirs, :files, keyword_init: true)
root = ElfDir.new(parent: nil, name: '/', dirs: {}, files: {})
current_dir = nil

input_lines('07').each do |line|
  case line
  when /\$ cd (?<dir_name>.*)/
    dir_name = Regexp.last_match[:dir_name]
    current_dir =
      case dir_name
      when '..'then current_dir.parent || current_dir
      when '/' then root
      else current_dir.dirs[dir_name]
      end
  when /dir (?<dir_name>.*)/
    dir_name = Regexp.last_match[:dir_name]
    current_dir.dirs[dir_name] ||= ElfDir.new(parent: current_dir, name: dir_name, dirs: {}, files: {})
  when /(?<file_size>[1-9]\d*) (?<file_name>.*)/
    current_dir.files[Regexp.last_match[:file_name]] ||= Regexp.last_match[:file_size].to_i
  end
end

dir_sizes = nested_dirs(root).map { |dir| total_size(dir) }

puts dir_sizes.sum { |file_size| file_size > 100_000 ? 0 : file_size }

total_disk_space = 70_000_000
unused_space_needed = 30_000_000
total_space_used = total_disk_space - total_size(root)
puts dir_sizes.sort.find { |s| total_space_used + s >= unused_space_needed }

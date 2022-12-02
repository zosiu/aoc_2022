# frozen_string_literal: true

require_relative 'helper'

class RPS
  @@choices = %w[✊ ✋ ✌️]
  @@opp_choices = %w[A B C]
  @@you_choices = %w[X Y Z]

  def self.victor_of(choice)
    @@choices[(@@choices.find_index(choice) + 1) % @@choices.count]
  end

  def self.victim_of(choice)
    @@choices[@@choices.find_index(choice) - 1]
  end

  def initialize(opp, you, cheat: false)
    @opp = @@choices[@@opp_choices.find_index(opp)]
    @you =
      if cheat
        case you
        when 'X' then self.class.victim_of(@opp)
        when 'Y' then @opp
        when 'Z' then self.class.victor_of(@opp)
        end
      else
        @@choices[@@you_choices.find_index(you)]
      end
  end

  def score(debug: false)
    puts to_s if debug

    @@choices.find_index(@you) + 1 +
      if self.class.victim_of(@you) == @opp
        6
      elsif self.class.victor_of(@you) == @opp
        0
      else
        3
      end
  end

  def to_s
    "#{@opp} #{@you} | #{score}"
  end
end

rps_rounds = input_lines('02').map(&:split)

puts rps_rounds.sum { |opp, you| RPS.new(opp, you).score }
puts rps_rounds.sum { |opp, you| RPS.new(opp, you, cheat: true).score }

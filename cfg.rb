require 'pda'
require 'set'

class CFG
  attr_accessor :start, :rule
  @@state_num = 0

  def initialize(options = {})
    @start = options[:start]
    @rule = options[:rule]
  end

  def run(input)
    new_candidates = Set.new [input]
    while true
      puts new_candidates.size
      old_candidates, new_candidates = new_candidates, Set.new
      for c in old_candidates
        for i in 0...input.size
          for k, v in @rule
            for m in v
              if c[i, m.size] == m
                new_candidate = c.dup
                new_candidate[i, m.size] = k
                return true if new_candidate == [@start]
                new_candidates.add new_candidate
              end
            end
          end
        end
      end
      break if new_candidates.size == 0
    end
    return false
  end

  def to_pda
    terminals = []
    @rule.each{|k,v| v.each{|a| a.each{|s| terminals << s unless s.is_a? Symbol}}}
    terminals.uniq!

    transition = {
      :q_start => { EMPTY => [[EMPTY, '$', :q_middle]] },
      :q_middle => { EMPTY => [[EMPTY, @start, :q_loop]] },
      :q_loop => { EMPTY => [['$', EMPTY, :q_accept]] },
      :q_accept => {}
    }
    for terminal in terminals
      transition[:q_loop].merge!({ terminal => [[terminal, EMPTY, :q_loop]] })
    end
    for k, v in @rule
      for single in v
        if single.size == 1
          transition[:q_loop][EMPTY] << [k, single[0], :q_loop]
        else
          stack_push = single.reverse
          next_state = new_state
          transition[:q_loop][EMPTY] << [k, stack_push[0], next_state]
          for s in stack_push[1..-2]
            now_state = next_state
            next_state = new_state
            transition[now_state] = { EMPTY => [[EMPTY, s, next_state]] }
          end
          transition[next_state] = { EMPTY => [[EMPTY, stack_push[-1], :q_loop]] }
        end
      end
    end
    PDA.new :start => :q_start, :end => :q_accept, :transition => transition
  end

private

  def new_state
    @@state_num = @@state_num + 1
    @@state_num.to_s.to_sym
  end
end

if $PROGRAM_NAME == __FILE__
  c = CFG.new({
    :start => :expr,
    :rule => {
      :digit => [[:digit, :digit]] + (0..9).to_a.map{|s| [s.to_s]},
      :expr => [[:expr, '+', :term], [:term]],
      :term => [[:term, '*', :factor], [:factor]],
      :factor => [['(', :expr, ')'], [:digit]]
    }
  })
  p c.rule
  p c.run(%w[2 + 3 * 4 4 +])
end


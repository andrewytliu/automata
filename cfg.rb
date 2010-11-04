class CFG
  attr_accessor :start, :rule

  def initialize(options = {})
    @start = options[:start]
    @rule = options[:rule]
  end

  def run(input)
    new_candidates = {input => true}
    while true
      old_candidates = new_candidates.keys
      new_candidate = {}
      for c in old_candidates
        for i in 0...input.size
          for k, v in @rule
            for m in v
              if c[i, m.size] == m
                new_candidate = c.dup
                new_candidate[i, m.size] = k
                return true if new_candidate == [@start]
                new_candidates[new_candidate] = true
              end
            end
          end
        end
      end
      break if new_candidates.size == 0
    end
    return false
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
  p c.run(%w[2 + 3 * 4 4])
end


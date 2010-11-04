class CFG
  def initialize(options = {})
    @start = options[:start]
    @rule = options[:rule]
  end

  def run(input)
    candidate = [input]
    while true
      #p input
      old_candidate = candidate.dup
      for c in old_candidate
      #rule_used = false
        for i in 0...input.size
          for k, v in @rule
            for m in v
              if c[i, m.size] == m
                #p "matched: ", m
                new_candidate = c.dup
                new_candidate[i, m.size] = k
                return true if new_candidate == [@start]
                candidate << new_candidate unless candidate.include? new_candidate
                #rule_used = true
                #break
              end
            end
            #break if rule_used
          end
          #break if rule_used
        end
      end
      break if old_candidate == candidate
      #break unless rule_used
    end
    return false
  end
end

if $PROGRAM_NAME == __FILE__
  c = CFG.new({
    :start => :expr,
    :rule => {
      :expr => [[:expr, '+', :term], [:term]],
      :term => [[:term, '*', :factor], [:factor]],
      :factor => [['(', :expr, ')'], ['a']]
    }
  })

  p c.run(%w[a + a * a +])
end


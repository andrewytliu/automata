require 'nfa'

class REG
  def initialize(exp)
    @nfa = nfa(exp.split(''))
  end

  def run(input)
    @nfa.run input
  end

private
  def nfa(exp)
    stack = [[]]
    for i in exp
      if i == '('
        stack.push []
      elsif i == ')'
        sub_exp = stack.pop
        stack[-1] << nfa(sub_exp)
      else
        stack[-1] << i
      end
    end
    for i in 0...stack[-1].length
      stack[-1][i] = NFA.new stack[-1][i] unless stack[-1][i].is_a? NFA or stack[-1][i] == '|' or stack[-1][i] == '*'
    end
    while stack[-1].include? '*'
      index = stack[-1].index('*')
      stack[-1][index-1].repeat!
      stack[-1].delete_at(index)
    end
    i = 0
    while i < stack[-1].length - 1
      unless stack[-1][i+1] == '|' or stack[-1][i] == '|'
        stack[-1][i] = stack[-1][i] + stack[-1][i+1]
        stack[-1].delete_at(i+1)
      else
        i = i + 1
      end
    end
    result = stack[-1][0]
    for i in 1...stack[-1].length
      if stack[-1][i] != '|'
        result = result | stack[-1][i]
      end
    end
    result
  end
end

if $PROGRAM_NAME == __FILE__
  r = REG.new '(abc)*'

  p r.run(%w[a b c a b c])
  p r.run(%w[a b c a])
  p r.run(%w[c c])
end


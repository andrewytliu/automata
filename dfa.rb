class DFA
  attr_accessor :start, :end, :transition

  def initialize(options = {})
    @start = options[:start]
    @end = options[:end]
    @transition = options[:transition]
  end

  def run(input)
    current_state = @start
    for i in input
      current_state = @transition[current_state][i]
    end
    return true if @end.include? current_state
    return false
  end
end

if $PROGRAM_NAME == __FILE__
  d = DFA.new(:start => :q1, :end => [:q2],
              :transition =>
              { :q1 => {0 => :q1, 1 => :q2},
                :q2 => {0 => :q3, 1 => :q2},
                :q3 => {0 => :q2, 1 => :q3}
              })

  puts d.run([1,1,0,0])
  puts d.run([1,1,0,0,0])
  puts d.run([0,0,0])
end


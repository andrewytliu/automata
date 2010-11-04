EMPTY = :epsilon

class PDA
  attr_accessor :start, :end, :transition

  def initialize(options = {})
    @start = options[:start]
    @end = options[:end]
    @transition = options[:transition]
  end

  def run(input)
    current_states = expand([[@start, []]])
    for i in input
      p current_states
      current_states = next_states(current_states, i)
      current_states = expand(current_states)
      current_states.uniq!
      return false if current_states.length == 0
    end
    current_states.each {|s| return true if @end.include? s }
    return false
  end

private

  def migrate(current, next_vector)
    current_state, stack = current.dup
    stack_top, stack_push, next_state = next_vector.dup
    if stack[-1] == stack_top or stack_top == EMPTY
      new_stack = stack.dup
      new_stack.pop unless stack_top == EMPTY
      new_stack.push(stack_push) unless stack_push == EMPTY
      return [next_state, new_stack]
    end
    return nil
  end

  def next_states(states, input)
    #p "states: ", states
    states.inject([]) do |result, state|
      if @transition[state[0]] and @transition[state[0]][input]
        next_states = @transition[state[0]][input]
        for s in next_states
          #p "before migrate", states
          migrated = migrate state, s
          #p "after migrate", states
          result << migrated if migrated
        end
      end
      #p "after next states", states
      result
    end
  end

  def expand(states)
    new_states = states
    #i= 0
    while true
      #p states
      new_states = next_states(new_states, EMPTY)
      #p new_states
      #p states
      new_states = new_states - states
      #p new_states
      #p "end"
      #return if i == 1
      #i = i+ 1
      return states if new_states == []
      states = states + new_states
    end
  end
end

if $PROGRAM_NAME == __FILE__
  n = PDA.new(:start => :q1, :end => [:q1, :q4],
              :transition =>
              { :q1 => {EMPTY => [[EMPTY, '$', :q2]]},
                :q2 => {0 => [[EMPTY, 0, :q2]], 1 => [[0, EMPTY, :q3]]},
                :q3 => {1 => [[0, EMPTY, :q3]], EMPTY => [['$', EMPTY, :q4]]},
                :q4 => {}
              })
  #p n.send :next_states, [[:q1, []]], EMPTY
  #p n.send :next_states, [[:q2, ["$"]]], EMPTY
  #p "expand"
  #p n.send :expand, [[:q1, []]]
  puts n.run([0,0,1,1])
#  puts n.run([0])
#  puts n.run([1,1,0,0])
#  puts n.run([1,1,0])
end


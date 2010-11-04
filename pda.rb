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
      current_states = next_states(current_states, i)
      current_states = expand(current_states)
      current_states.flatten!.uniq!
      return false if current_states.length == 0
    end
    current_states.each {|s| return true if @end.include? s }
    return false
  end

private

  def migrate(current, next_vector)
    current_state, stack = current
    stack_top, stack_push, next_state = next_vector
    if stack[-1] == stack_top or stack_top == EMPTY
      stack.pop unless stack_top == EMPTY
      stack.push(stack_push) unless stack_push == EMPTY
      return [next_state, stack.dup]
    end
    return nil
  end

  def next_states(states, input)
    states.inject([]) do |n,state|
      if @transition[state[0]] and @transition[state[0]][input]
        next_states = @transition[state[0]][input]
        for s in next_states
          migrated = migrate state, s
          e << migrated if migrated
        end
      end
      n
    end
  end

  def expand(states)
    last_new_states = []
    while true
      new_states = states.inject([]) do  |e,state|
        if @transition[state[0]] and @transition[state[0]].include? EMPTY
          next_states = @transition[state[0]][EMPTY]
          for s in next_states
            migrated = migrate state, s
            e << migrated if migrated
          end
        end
        e
      end
      return states unless new_states != [] and new_states != last_new_states
      last_new_states = new_states
      states = (states + new_states).uniq
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

  puts n.run([0,0,1,1])
  puts n.run([0])
  puts n.run([1,1,0,0])
  puts n.run([1,1,0])
end


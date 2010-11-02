EMPTY = :epsilon

class NFA
  attr_accessor :start, :end, :transition

  def initialize(options = {})
    if options.is_a? Hash
      @start = options[:start]
      @end = options[:end]
      @transition = options[:transition]
    else
      @start = new_state
      @end = [new_state]
      @transition = {  @start => {options => @end.dup} }
    end
  end

  def run(input)
    current_states = expand([@start])
    for i in input
      current_states = current_states.inject([]) {|n,s| (@transition[s] and @transition[s][i]) ? n << @transition[s][i] : n }.flatten
      current_states = expand(current_states)
      current_states.flatten!
      return false if current_states.length == 0
      current_states.uniq!
    end
    current_states.each {|s| return true if @end.include? s }
    return false
  end

  def concat(right)
    result = self.dup
    result.transition.merge! right.transition
    result.end.each do |s|
      result.transition[s] ||= {}
      result.transition[s][EMPTY] ||= []
      result.transition[s][EMPTY] << right.start
    end
    result.end = right.end.dup
    result
  end

  def union(right)
    result = self.dup
    result.transition.merge! right.transition
    new_start = new_state
    result.transition[new_start] = { EMPTY => [start, right.start] }
    result.end = result.end + right.end
    result.start = new_start
    result
  end

  def star!
    new_start = new_state
    @end.each do |s|
      @transition[s] ||= {}
      @transition[s][EMPTY] ||= []
      @transition[s][EMPTY] << @start
    end
    @transition[new_start] = { EMPTY => [@start] }
    @start = new_start
    @end << @start
    self
  end

private
  def new_state
    require 'digest/sha1'
    sha1 = Digest::SHA1.hexdigest(Time.now.to_s + rand.to_s).to_sym
  end

  def expand(states)
    last_new_states = []
    while true
      new_states = states.inject([]) {|e,s| (@transition[s] and @transition[s].include? EMPTY) ? e << @transition[s][EMPTY] : e}.flatten.uniq
      return states unless new_states != [] and new_states != last_new_states
      last_new_states = new_states
      states = (states + new_states).uniq
    end
  end
end

if $PROGRAM_NAME == __FILE__
  n = NFA.new(:start => :q1, :end => [:q4],
              :transition =>
              { :q1 => {0 => [:q1], 1 => [:q2, :q1]},
                :q2 => {0 => [:q3], EMPTY => [:q3]},
                :q3 => {1 => [:q4]},
                :q4 => {0 => [:q4], 1 => [:q4]}
              })

  puts n.run([0,1,0,1,1,0])
  puts n.run([0,0,0])
  puts n.run([1,0,0,1])
  puts n.run([1,1])
end


class Stream
  include Enumerable

  def initialize(facts)
    @facts = facts
  end

  def each(&block)
    @facts.each &block
  end

end

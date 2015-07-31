class Factset
  include Enumerable

  def initialize(facts)
    @facts = facts
  end

  def each(&block)
    @facts.each &block
  end

  def +(facts)
    Factset.new @facts + facts
  end

end

require 'fact_store'

class Ruleset

  def initialize(*rules)
    @rules = rules
  end

  def apply(stream)
    transaction = FactStore::Transaction.new

    rules.each do |rule|
      rule.apply(stream).each do |entry|
        transaction << entry
        stream += entry.facts
      end
    end

    transaction
  end

end
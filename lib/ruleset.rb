require 'fact_store'

class Ruleset

  def initialize(*rules)
    @rules = rules
  end

  def apply(factset)
    transaction = FactStore::Transaction.new

    rules.each do |rule|
      rule.apply(factset).each do |entry|
        transaction << entry
        factset += entry.facts
      end
    end

    transaction
  end

end

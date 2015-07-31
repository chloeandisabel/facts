require 'pql'
require_relative '../lib/rule.rb'
require_relative '../lib/ontology.rb'
require_relative '../lib/factset.rb'
require 'test/unit'


Ontology.define do
  type :A
  type :B
end


class ExampleRule < Rule

  pattern <<-PQL
    MATCH EACH AS a WHERE type IS "A";
    MATCH ALL AS b WHERE type IS "B";
  PQL

  action do |e|
    e.A
  end

end


class ExampleRuleWithMethod < Rule

  pattern <<-PQL
    MATCH ALL AS a WHERE type IS "A";
  PQL

  method :test_method do
    1
  end

  action do |t|
    @@result = test_method
  end

  def result
    @@result
  end

end



class TestRule < Test::Unit::TestCase

  def test_rule
    rule = ExampleRule.new
    factset = Factset.new [
      {id: 1, type: 'A'},
      {id: 2, type: 'A'},
      {id: 3, type: 'B'},
      {id: 4, type: 'B'}
    ]

    entries = rule.apply factset
    assert entries.length == 2, 'rule should return an array of 2 entries'
    assert entries.all?{|e| e.facts.length == 1}, 'rule should write one fact in each entry'
  end

  def test_rule_method
    rule = ExampleRuleWithMethod.new

    factset = Factset.new [{id: 1, type: 'A'}]

    entries = rule.apply factset
    assert entries.length == 1
    assert rule.result == 1
  end

end

require 'pql'
require_relative '../lib/rule.rb'
require 'test/unit'


class ExampleRule < Rule

  pattern <<-PQL
    MATCH EACH AS a WHERE type IS "A";
    MATCH ALL AS b WHERE type IS "B";
  PQL

  action do |t|
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

    stream = [
      {id: 1, type: 'A'},
      {id: 2, type: 'A'},
      {id: 3, type: 'B'},
      {id: 4, type: 'B'}
    ]

    entries = rule.apply stream
    assert entries.length == 2, 'rule should return an array of 2 entries'
  end

  def test_rule_method
    rule = ExampleRuleWithMethod.new

    stream = [
      {id: 1, type: 'A'}
    ]

    entries = rule.apply stream
    assert entries.length == 1
    assert rule.result == 1
  end

end
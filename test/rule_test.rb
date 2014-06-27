require_relative '../lib/parser.rb'
require_relative '../lib/rule.rb'
require 'test/unit'


class ExampleRule < Rule

  @@counter = 0

  def counter
    @@counter
  end

  pattern <<-PQL
    MATCH EACH AS a WHERE type IS "A";
    MATCH ALL AS b WHERE type IS "B";
  PQL

  action do |t|
    @@counter += 1
  end
end



class TestRule < Test::Unit::TestCase

  def test_rule
    rule = ExampleRule.new

    assert rule.counter == 0, 'counter should initially be 0'

    stream = [
      {id: 1, type: 'A'},
      {id: 2, type: 'A'},
      {id: 3, type: 'B'},
      {id: 4, type: 'B'}
    ]

    rule.apply stream

    assert rule.counter == 2, 'rule should run twice'
  end

end
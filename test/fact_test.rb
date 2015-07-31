require_relative '../lib/ontology.rb'
require_relative '../lib/fact.rb'
require 'test/unit'

Ontology.define do
  type :A, [:X, :Y, :Z]
  type :B, [:A, :C]
  type :C, [:D, :E]
end

class TestFactTyping < Test::Unit::TestCase
  def test
    assert Fact.new(type: :A).types == Set.new([:A, :Z, :X, :Y]), 'should save types'
    assert Fact.new(type: :B).types == Set.new([:B, :A, :Z, :X, :Y, :C, :D, :E]), 'should include types of parent types, even if defined afterwards'
    assert Fact.new(type: :C).types == Set.new([:C, :D, :E]), 'should work here too'
  end
end

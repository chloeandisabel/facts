require_relative '../lib/event.rb'
require 'test/unit'

Ontology.define do
  type :A, [:X, :Y, :Z]
  type :B, [:A, :C]
  type :C, [:D, :E]
end

class TestEventTyping < Test::Unit::TestCase
  def test
    assert Event.new(type: :A).types == Set.new([:A, :Z, :X, :Y]), 'should save types'
    assert Event.new(type: :B).types == Set.new([:B, :A, :Z, :X, :Y, :C, :D, :E]), 'should include types of parent types, even if defined afterwards'
    assert Event.new(type: :C).types == Set.new([:C, :D, :E]), 'should work here too'
  end
end
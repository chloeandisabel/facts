require 'set'

class Ontology

  @@directory = {}

  # return a list of all defined types
  def self.types
    @@directory.keys
  end
  
  # return true if a type has been defined
  def self.include?(name)
    @@directory.has_key? name
  end

  # look up exhaustive list of all types a given type belongs to
  def self.lookup(name)
    @@directory[name].reduce Set.new([name]) do |memo, type|
      memo.merge(@@directory.has_key?(type) ? self.lookup(type) : [type])
    end
  end

  def self.define(&block)
    class_eval &block
  end

  private

  # define a fact type w/ multiple inheritance
  def self.type(name, parents = [])
    @@directory[name] = parents
  end

end

require 'uuid'
require 'fact'

class Entry

  def initialize(description, header, cause = [], attrs = {})
    @description = description
    @header = header
    @cause = cause
    @attrs = attrs
    @id = UUID.new
    @facts = []
  end

  attr_reader :facts

  def [](key)
    return instance_variable_get(key) if [:id, :description].include? key
    @attrs[key]
  end

  def method_missing(name, attrs={})
    if Ontology.include? name
      @facts.push Fact.new(attrs.merge(@header).merge(type: name, caused_by: @cause))
    else
      super
    end
  end

end

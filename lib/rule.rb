require 'set'
require 'pql'
require 'entry'

class Rule

  # defaults for dynamically defined methods

  @header = Set.new
  @description = ''
  @pattern = PQL::Block.new '', 0..0
  @methods = {}
  @action = ->(){}


  # force subclasses to inherit class instance variables

  def self.inherited(subclass)
    [:@pattern, :@methods, :@action, :@header, :@description].each do |v|
      subclass.instance_variable_set(v, self.instance_variable_get(v))
    end
  end


  # instance methods

  def description
    self.class.instance_variable_get :@description
  end

  def pattern
    self.class.instance_variable_get :@pattern
  end

  def methods
    self.class.instance_variable_get :@methods
  end

  def action
    self.class.instance_variable_get :@action
  end

  def header_for(factset)
    ordered_facts = factset.sort_by{|e| e[:created_at]}
    self.class.instance_variable_get(:@header).reduce({}) do |header, column|
      source = ordered_facts.find{|f| f[column].present?}
      header[column] = source[column] if source
      header
    end
  end

  def apply(factset)
    header = header_for factset
    pattern.apply(factset).map do |matches|
      cause = matches.values.map(&:events).flatten.map{|e| e[:id]}.uniq
      entry = Entry.new description, header, cause
      ActionBlockHelper.new(methods, matches).instance_exec entry, &action
      entry
    end
  end



  # class methods used to define subclasses

  private

  def self.description(description)
    @description = description
  end

  def self.header(*columns)
    @header += columns
  end

  def self.pattern(pql)
    @pattern = PQL::Parser.parse pql
  end

  def self.method(name, &block)
    @methods ||= {}
    @methods[name] = block
  end

  def self.action(&block)
    @action = block
  end



  # action context

  class ActionBlockHelper
    def initialize(methods, matches)
      @methods = methods
      @matches = matches
    end

    def method_missing(name, *args)
      return instance_exec(*args, &@methods[name]) if @methods.has_key? name
      return @matches[name].singular ? @matches[name].events.first : @matches[name].events if @matches.has_key? name
      super name, *args, &block
    end
  end

end

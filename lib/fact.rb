class Fact

  def initialize(attrs)
    @attrs = attrs
    @attrs[:id] ||= UUID.new
  end

  def [](key)
    @attrs[key]
  end

  def types
    Ontology.lookup @attrs[:type]
  end

  def has_type?(type)
    types.include? type
  end

  def causes?(event)
    event[:caused_by].include? @attrs[:id]
  end

  def caused_by?(event)
    @attrs[:caused_by].include? event[:id]
  end

  def to_hash
    @attrs.merge types: types
  end

  def respond_to?(name, include_private = false)
    @attrs.has_key?(name) || super(name, include_private)
  end

  def method_missing(name, *args, &block)
    if args.none? && @attrs.has_key? name
      @attrs[name]
    else
      super name, *args, &block
    end
  end

end
Gem::Specification.new do |s|
  s.name          = 'facts'
  s.version       = '0.0.0'
  s.date          = '2014-06-26'
  s.summary       = 'Fact, Rule, and associated classes'
  s.description   = 'Base classes for event sourcing and a rule system.'
  s.authors       = ['Charlie Schwabacher']
  s.email         = 'charlie.schwbacher@chloeandisabel.com'
  s.files         = ['lib/entry.rb', 'lib/fact.rb', 'lib/facts.rb',
                     'lib/fact_store.rb', 'lib/ontology.rb', 'lib/rule.rb',
                     'lib/ruleset.rb', 'lib/factset.rb', 'lib/uuid.rb']

  s.add_runtime_dependency 'pql'
  s.add_runtime_dependency 'mysql2'
  s.add_runtime_dependency 'macaddr'
end

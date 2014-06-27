Gem::Specification.new do |s|
  s.name        = 'facts'
  s.version     = '0.0.0'
  s.date        = '2014-06-26'
  s.summary     = 'Pattern Query Language'
  s.description = 'Base classes for event sourcing and a rule system.'
  s.authors     = ['Charlie Schwabacher']
  s.email       = 'charlie.schwbacher@chloeandisabel.com'
  s.files       = ['lib/entry.rb', 'lib/fact.rb', 'lib/event_store.rb',
                   'lib/ontology.rb', 'lib/parser.rb', 'lib/rule.rb',
                   'lib/ruleset.rb', 'lib/stream.rb']
  s.homepage    = 'https://bitbucket.org/charlieschwabacher/pql'

  s.add_runtime_dependency 'pql'
  s.add_runtime_dependency 'mysql2'
  s.add_runtime_dependency 'macaddr'
end
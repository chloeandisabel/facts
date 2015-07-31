
Facts
=====

This repo provides base classes for modeling event sourced data and describing buisness logic w/ declarative rules.


### Facts

Facts are immutable records of events that occur in the world or in our application.  Instead of storing the current state of objects in a problem domain, we can use events to store their history of changes.  From the history, we can recreate their state at any point in time and can audit the state changes that brought them there.

In terms of code, facts can be thought of as hashes w/ a unique id, type, set of causes, and any number of other named attributes.

```ruby
fact = Fact.new name: 'A'
fact.name   # 'A'
fact[:name] # 'A'
```


### Rules

Rules describe a pattern using a block of PQL code, and then accept a block of ruby code to run for each successful match.  The block is run in a context with methods defined for each of the pattern's named matches.  Methods can also be defined, and will run in same context as the action.

The action block is passed one argument, 'e', an `Entry` instance.  The entry has methods available to write each type of fact in the ontology.

Facts written by the rule will store their *cause*, a list of all the ids of the facts making up the current match.  Facts written by the rule also include a number of default attributes enumerated as the rule's *header*.  The rule will pass the value for each of these attributes from the most recent fact from the subject set to the entry, which will include them in every new fact that it creates.


```ruby
class PerItemDiscountAccountingRule < Rule

  description 'split order level discounts across individual items'

  header :user_id, :order_id

  pattern <<-PQL
    MATCH EACH AS item WHERE type IS 'ItemAddedToCart';
    MATCH EACH AS discount WHERE type IS 'OrderLevelDiscountApplied';
  PQL

  method :amount do
    discount.percent * item.amount
  end

  action do |e|
    e.order_level_discount_applied_to_item(
      sku: item.sku,
      promotion_id: discount.promotion_id,
      amount: amount
    )
  end
end
```


### Entries

Entries store metadata around the creation of facts and are produced each time a rule is applied.  Entries provide a record of a group of facts created together, the reason for their creation, and the line number and git sha of the source code responsible for their creation.

Entries also provide a shorthand for writing verbose fact headers.  When an entry is created, it is passed a hash as a *header* to be included as attributes of each fact it writes.


### Rulesets

Rulesets wrap ordered sets of rules, and can apply them in order to a set of facts.  Facts produced by each rule are appended to the set of facts before the next is applied.

Applying a ruleset returns a single `Transaction` object.

```ruby
ruleset = Ruleset.new(
  InventoryCheckRule.new,
  DiscountRule.new(threshold: 50, percent: 15),
  StoreCreditApplicationRule.new
)

transaction = ruleset.apply(factset)

transaction.persist!
```


### Transactions

Transactions record many entries and facts in single round trip to the database.

```ruby
transaction = FactStore::Transaction.new
transaction << entry
transaction.persist!
```

Transactions are by default non-atomic, but atomic transactions can be created by passing an `atomic: true` option to their constructor.



### Facts and Ontology

The fact *ontology* represents types as a directed acyclic graph, where each type is a node having edges directed from itself to any number of parent types.  A type's ancestors are the set of all reachable nodes.  Facts are considered to be members of their own type and of each of its ancestor types.

```ruby
Ontology.define do
  type :A, [:B, :C]
  type :D, [:A]
end
```

 In this example, an fact of type 'A' will belong to the types 'A', 'B', and 'C', and an fact of type 'D' will belong to the types 'D', 'A', 'B', and 'C'.



### Fact Store

The fact store is used to query persisted facts.

```ruby
FactStore.query type: 'ItemAddedToCart', sku: 'ABC1'
```
 A Query to the fact store returns a Factset, containing all facts matching the given conditions.


---


API
---

(still in progress)

#### Entry

> `Entry::initialize(description, header, cause = [], attrs = {})`

> `Entry#facts`

> `Entry#[](key)`

> `Entry#{{fact_type}}`



#### Fact

> `Fact::initialize(attributes)` creats a new, immutable, fact instance with the given attributes.

> `Fact#[](key)` returns the value of the attribute with the given key.

> `Fact#{{attribute}}` returns the value of the attribute

> `Fact#types` returns a list of all types the fact belongs to based on its `:type` attribute and the fact ontology.

> `Fact#has_type?(type)` returns `true` if the fact is a member of the given type, `false` otherwise.

> `Fact#causes?(fact)` returns `true` if the fact is a cause of the given fact, `false` otherwise.

> `Fact#caused_by?(fact)` returns `true` if the fact is caused by the given fact, `false` otherwise.

> `Fact#to_hash` returns the facts attributes as a `Hash`.



#### Fact::Ontology

> `Fact::Ontology::define(&block)` runs the given block in a context w/ the `Fact::Ontology::type` method available.

> `FactOntology::type(name, parents = [])` (*private*) defines a new type with the given name belonging to the given parent types.   Expects name and parents to be symbols.

> `Fact::Ontology::types` returns an array of all defined types.

> `Fact::Ontology::include?(type)` returns `true` if the given type has been defined, `false` otherwise.

> `Fact::Ontology::lookup(type)` returns an array of all types the given type belongs to (including the given type).



#### FactStore

> `FactStore::query(attributes)` queries the database for facts matching the given attributes, returns an enumerable `Factset` object.



#### FactStore::Transaction

> `FactStore::Transaction::initialize(options)` creates a new, empty, trasaction.  Accepts a boolean 'atomic' option.

> `FactStore::Transaction#<<(entry)` appends an entry to the transaction.  If the transaction has already been persisted, instead raises an error.

> `FactStore::Transaction#persist!` writes the appended entries and facts to the database.  Returns `true` if the operation succeeds, `false` otherwise.

> `FactSTore::Transaction#persisted?` returns `true` if the transaction has sucessfully written facts to the database, `false` otherwise.



#### Rule

> `Rule::description(description)` (*private*)

> `Rule::header(*columns)` (*private*)

> `Rule::pattern(pql)` (*private*)

> `Rule::method(name, &block)` (*private*)

> `Rule::action(&block)` (*private*)

> `Rule#description`

> `Rule#pattern`

> `Rule#methods`

> `Rule#action`

> `Rule#header_for(factset)`

> `Rule#apply(factset)`



#### Ruleset

> `Ruleset::initialize(*rules)` - creates a new ruleset w/ given rules

> `Ruleset#apply(factset)` - applies the rules in order to the factset, returns a `Transaction` wrapping resulting entries



#### Factset (enumerable)

> `Factset::initialize(facts)`

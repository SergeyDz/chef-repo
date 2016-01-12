# magic ![Version](https://img.shields.io/cookbook/v/magic.svg?style=flat-square)

A library cookbook meant to make writing cookbooks a bit easier. It exposes
some helpful functions, which you can use directly in recipes and resources.
This cookbook has no attributes, no recipes, and no dependencies. All Linux
(and probably other Unix-like) platforms are supported.


## Helpers

Declared under the `Helpers` module in `libraries/helpers.rb`.

`file_cache_path` is a simpler way to use `Chef::Config[:file_cache_path]`:

```ruby
file_cache_path # => '/var/cache/chef'
file_cache_path 'cached.file' # => '/var/cache/chef/cached.file'
file_cache_path 'my', 'other.file' # => '/var/cache/chef/my/other.file'
```

`resource?` can be used to ask whether or not a resource exists:

```ruby
resource? 'this_thing[doesnt_exist]' # => false
resource? 'thing_thing[totally_exists]' # => true
```

`shell_opts` can translate a Hash into a shell-friendly string of options:

```ruby
shell_opts({ debug: true, simon: 'says' }) # => '--debug --simon says'
shell_opts({ debug: false, level: 2 }) # => '--level 2'
```

`upstart_opts` works like `shell_opts` for Upstart:

```ruby
upstart_opts({ debug: true, simon: 'says' }) # => "--debug --simon 'says'"
upstart_opts({ debug: false, level: 2 }) # => "--level '2'"
```

## Search

`search_nodes` is a light abstraction over Chef search, which allows you to
make queries using a plain old Ruby Hash:

```ruby
search_nodes chef_environment: 'example', role: 'test'
# => search(:node, 'chef_environment:"example" AND role:"test"')
search_nodes chef_environment: 'example', role: 'test', join_with: 'OR'
# => search(:node, 'chef_environment:"example" OR role:"test"')
```


## Deep Merge

This library extends the Ruby `Hash` class with deep merge capabilities from
Chef's own `DeepMerge` mixin:

```ruby
{ a: 1, b: { c: 2 } }.deep_merge b: { d: 4 }, c: 3
# => { a: 1, b: { c: 2, d: 4 }, c: 3 }
```


## Configuration

Declared under the `Configuration` module in `libraries/configuration.rb`.


### INI

Converts a Hash to INI-style configuration:

```ruby
ini_config({
  'this' => {
    'is' => 'an',
    'example' => 123
  }
})
```

Generates:

```
[this]
is=an
example=123
```


### YAML

Converts a Hash to YAML:

```ruby
yaml_config({
  'this' => {
    'is' => %w[ just a test ]
  }
})
```

Generates:

```
---
this:
  is:
  - just
  - a
  - test
```


### JSON

Converts a Hash to JSON and returns a pretty representation:

```ruby
json_config({
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil,
    {} => [],
    'deal' => /really/
  }
})
```

Generates:

```json
{
  "this": {
    "is": [ "just", "a", "FREEFORM" ],
    "10": null,
    "{}": [],
    "deal": "(?-mix:really)"
  }
}
```


### Java

Converts a Hash to Java-style configuration:

```ruby
java_config({
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil
  }
})
```

Generates:

```
this {
  is = [ "just", a, "FREEFORM" ]
  10 = nil
}
```


### Java Properties

Converts a Hash to [Java properties](https://github.com/jnbt/java-properties):

```ruby
properties_config({
  'foo' => 'bar'
})
```

Generates:

```
foo=bar
```


### Logstash

**N.B.** The name of this generator changed in `v1.2` from `logstash_config`
to `logstash_typed_config` to avoid a namespace collision (per Issue #5).

Converts a Hash to Logstash-style configuration:

```ruby
logstash_typed_config({
  'input' => {
    'test' => {
      'file' => {
        'path' => '/var/log/test.log'
      }
    }
  },
  'filter' => {
    'test' => {
      'seq' => {}
    }
  },
  'output' => {
    'test' => {
      'stdout' => {
        'codec' => 'rubydebug'
      }
    }
  }
})
```

Generates:

```
input {
  file {
    path => "/var/log/test.log"
    type => "test"
  }
}
filter {
  if [type] == "test" {
    seq {
    }
  }
}
output {
  if [type] == "test" {
    stdout {
      codec => "rubydebug"
    }
  }
}
```


### Exports

Converts a Hash to shell exports-style configuration:

```ruby
exports_config({
  'this' => nil,
  'is' => 10,
  'a' => :nother,
  'test' => 1234
})
```

Generates:

```ruby
export this=''
export is=10
export a=nother
export test=1234
```



## Materialization


Materialization lets you pull a neat trick by phrasing string attributes in terms of other string attributes, so you can have attributes files that look like this:

```ruby
# attributes/default.rb
default['example']['version'] = '1.2.3'
default['example']['url'] = 'http://example.com/%{version}.tar.gz'
```

At runtime, materialization will replace `%{version}` with the `node.example.version` attibute.

If you're familiar with string interpolation tricks in Ruby (aren't we all?), this should feel familiar:

```
$ irb
irb> puts '%{one} %{two} %{three}' % { one: 1, two: 2, three: 3 }
1 2 3
=> nil
```

The only innovation with materialization is that the interpolation is applied recursively:

```ruby
# libraries/materialization.rb
module Materialization
  def sym k ; k.respond_to?(:to_sym) ? k.to_sym : k end

  def materialize obj, parent=nil
    o = materialize_raw obj, parent
    return ::Chef::Mash.new(o) if o.is_a? Hash
    return o
  end

  def materialize_raw obj, parent=nil
    obj = obj.to_hash if obj.respond_to? :to_hash
    if obj.is_a? Hash
      obj = obj.inject({}) { |memo, (k,v)| memo[sym(k)] = v ; memo }
      obj.inject({}) { |memo, (k,v)| memo[sym(k)] = materialize_raw(v, obj) ; memo }
    elsif obj.is_a? Array
      obj.map { |o| materialize_raw(o, parent) }
    elsif obj.is_a? String
      obj % parent rescue obj
    else
      obj
    end
  end
end
```

That's an ugly chunk of code, but the results are intuitive enough:

```ruby
materialize nil # => nil

materialize 'hello' # => 'hello'

materialize 'hello %{world}', world: 'bob' # => 'hello bob'

materialize %w[ %{one} %{two} %{three} ], one: 1, two: 2, three: 3
# => [ '1', '2', '3' ]

materialize one: [ { one: '%{two}', two: 2 } ], two: '%{three}', three: 4
# => { one: [ { one: '2', two: 2 } ], two: '4', three: 4 }
```

Now in a recipe, you'd materialize the relevant attribute namespace:

```ruby
# recipes/default.rb
example = materialize node['example']
```

## Reification

Consider this code from a hypothetical `icinga2` cookbook:

```ruby
# attributes/default.rb
default['icinga2']['repo']['name'] = 'icinga2'
default['icinga2']['repo']['uri'] = 'ppa:formorer/icinga'
default['icinga2']['repo']['distribution'] = node['lsb']['codename']
```

```ruby
# recipes/default.rb
repo_spec = node['icinga2']['repo'].to_hash
repo_name = repo_spec.delete 'name'

apt_repository repo_name do
  repo_spec.each do |k, v|
    send k.to_sym, v
  end
end
```

We're just adding an apt repository, configured according to our attributes.

In a broad sense, we've got a Chef resource, and we're converting attributes in a namespace to method calls on the resource. The `name` attribute is required and passed along as the resource name.

We'll call this pattern _reification_:

```ruby
# libraries/reification.rb
# Simplified, see "Notifications and Actions" below
module Reification
  def reify resource, spec
    spec = ::Mash.new(spec.to_hash)
    name = spec.delete 'name'
    send resource.to_sym, name do
      spec.each do |k, v|
        send k.to_sym, v
      end
    end
  end
end
```

Now the cookbook is much tighter:

```ruby
# attributes/default.rb
default['icinga2']['repo']['name'] = 'icinga2'
default['icinga2']['repo']['uri'] = 'ppa:formorer/icinga'
default['icinga2']['repo']['distribution'] = node['lsb']['codename']
```

```ruby
# recipes/default.rb
reify :apt_repository, node['icinga2']['repo']
```

We might say that `reify` _instantiates_ a resource according to the provided attributes or _spec_.

### Notifications and Actions

The implementation of `reify` above is a bit simplified. The actual implementation
also supports resource notifications and actions. The function signature really
looks like `reify resource, spec, notifications=[], actions=[]`. Use it like so:

```ruby
reify :service, node['icinga2']['service'], [
  [ :restart, 'icinga-server' ], # Delayed by default
  [ :restart, 'icinga-sidecar', :immediately ]
], [ :enable, :start ]
```
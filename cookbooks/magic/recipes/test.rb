#
# Cookbook Name:: magic
# Recipe:: test
#
# Copyright (C) 2014 Blue Jeans Network
#

hash_a = {
  one: 1,
  two: 2,
  etc: {
    three: 3,
    four: 4
  }
}

hash_b = {
  three: 3,
  etc: {
    five: 5
  }
}

hash_ab = {
  one: 1,
  two: 2,
  three: 3,
  etc: {
    three: 3,
    four: 4,
    five: 5
  }
}

Chef::Log.fatal hash_a.deep_merge(hash_b)

Chef::Log.fatal hash_a

raise unless \
  hash_a.deep_merge!(hash_b) == hash_ab

raise unless \
  hash_a == hash_ab

reify :gem_package, {
  name: 'kffpt'
}, [
  [ :touch, 'file[/tmp/expect/ini.conf]' ]
], :upgrade

reify_packages({ 'vim' => {} }, [
  [ :create, 'directory[/tmp/expect]' ]
], :upgrade)

directory '/tmp/expect' if resource? 'gem_package[kffpt]'

raise unless \
  shell_opts({ debug: true, simon: 'says' }) == '--debug --simon says'

raise unless \
  shell_opts({ debug: false, level: 2 }) == '--level 2'

raise 'Materialization failed!' unless \
  materialize(nil) == nil

raise 'Materialization failed!' unless \
  materialize('hello') == 'hello'

raise 'Materialization failed!' unless \
  materialize('hello %{world}', world: 'bob') \
    == 'hello bob'

raise 'Materialization failed!' unless \
  materialize_raw(%w[ %{one} %{two} %{three} ], one: 1, two: 2, three: 3) \
    == [ '1', '2', '3' ]

raise 'Materialization failed!' unless \
  materialize_raw(one: [ { one: '%{two}', two: 2 } ], two: '%{three}', three: 4) \
    == { one: [ { one: '2', two: 2 } ], two: '4', three: 4 }

reify :package, { name: 'htop' }

node.default['configurator']['test']['logstash']['input'] = {
  'test' => {
    'file' => {
      'path' => '/var/log/test.log'
    }
  }
}

node.default['configurator']['test']['logstash']['filter'] = {
  'test' => {
    'seq' => {}
  }
}

node.default['configurator']['test']['logstash']['output'] = {
  'test' => {
    'stdout' => {
      'codec' => 'rubydebug'
    }
  }
}

file '/tmp/expect/logstash.conf' do
  content logstash_typed_config(node.default['configurator']['test']['logstash'])
end

file '/tmp/expect/logstash.conf.expect' do
  content %Q$
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
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['logstash_conditional_output'] = {
  'input' => {},
  'filter' => {},
  'output' => {
    "if 'test' in [tags]" => {
      'this' => {
        'is' => 'good'
      }
    }
  }
}

file '/tmp/expect/logstash_conditional_output.conf' do
  content logstash_typed_config(node.default['configurator']['test']['logstash_conditional_output'])
end

file '/tmp/expect/logstash_conditional_output.conf.expect' do
  content %Q$
    input {
    }
    filter {
    }
    output {
      if 'test' in [tags] {
        this {
          is => "good"
        }
      }
    }
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['json'] = {
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil,
    {} => [],
    'deal' => /really/
  }
}

file '/tmp/expect/json.conf' do
  content json_config(node.default['configurator']['test']['json'])
end

file '/tmp/expect/json.conf.expect' do
  content %Q$
    {
      "this": {
        "is": [
          "just",
          "a",
          "FREEFORM"
        ],
        "10": null,
        "{}": [

        ],
        "deal": "(?-mix:really)"
      }
    }
  $.strip.gsub(/^    /, '')
end


node.default['configurator']['test']['hocon'] = {
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil
  }
}

file 'tmp/expect/hocon.conf' do
  content hocon_config(node.default['configurator']['test']['hocon'])
end

file '/tmp/expect/hocon.conf.expect' do
  content %Q$
    {
        # hardcoded value
        "this" : {
            # hardcoded value
            "10" : null,
            # hardcoded value
            "is" : [
                # hardcoded value
                "just",
                # hardcoded value
                "a",
                # hardcoded value
                "FREEFORM"
            ]
        }
    }
  $.strip.gsub(/^    /, '')
end

node.default['configurator']['test']['java'] = {
  'this' => {
    'is' => [ 'just', :a, 'FREEFORM' ],
    10 => nil
  }
}

file '/tmp/expect/java.conf' do
  content java_config(node.default['configurator']['test']['java'])
end

file '/tmp/expect/java.conf.expect' do
  content %Q$
    this {
      is = [ "just", a, "FREEFORM" ]
      10 = nil
    }
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['exports'] = {
  nil => '#!/bin/sh',
  'this' => nil,
  'is' => 10,
  'a' => :nother,
  'test' => 1234
}

file '/tmp/expect/exports.conf' do
  content exports_config(node.default['configurator']['test']['exports'])
end

file '/tmp/expect/exports.conf.expect' do
  content %Q$
    #!/bin/sh
    export this=''
    export is=10
    export a=nother
    export test=1234
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['toml'] = {
  'this' => {
    'is' => 'just',
    'a' => 'test'
  },
  'hello' => {
    'world' => 1
  },
  'array_of_tables' => [
    {'something' => 'is'},
    {'going' => 'on', 'around' => 'here'}
  ]
}

file '/tmp/expect/toml.conf' do
  content toml_config(node.default['configurator']['test']['toml'])
end

file '/tmp/expect/toml.conf.expect' do
  content %Q$

    [[array_of_tables]]
    something = "is"

    [[array_of_tables]]
    around = "here"
    going = "on"

    [hello]
    world = 1

    [this]
    a = "test"
    is = "just"
  $.strip.gsub(/^    /, '')
end

node.default['configurator']['test']['ini'] = {
  'this' => {
    'is' => 'just',
    'a' => 'test'
  },
  'hello' => {
    'world' => 1
  }
}

file '/tmp/expect/ini.conf' do
  content ini_config(node.default['configurator']['test']['ini'])
end

file '/tmp/expect/ini.conf.expect' do
  content %Q$
    [this]
    is=just
    a=test

    [hello]
    world=1
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['yaml'] = {
  'this' => {
    'is' => 'just',
    'a' => 'test'
  }
}

file '/tmp/expect/yaml.conf' do
  content yaml_config(node.default['configurator']['test']['yaml'])
end

file '/tmp/expect/yaml.conf.expect' do
  content %Q$
    ---
    this:
      is: just
      a: test
  $.strip.gsub(/^    /, '')
end



node.default['configurator']['test']['inline'] = {
  'lines' => %w[ 1 2 3 ]
}

file '/tmp/expect/inline.conf' do
  content inline_config(node.default['configurator']['test']['inline'])
end

file '/tmp/expect/inline.conf.expect' do
  content %Q$
    1
    2
    3
  $.strip.gsub(/^    /, '')
end

erlang_hash = {
  "app_a" => {
    "atom_key" => {
      "hash_value_key" => '"string value"',
      "hash_value_key2" => '<<"binary value">>'
    },
    "another_key" => [
      {
        "proplist_key" => "proplist_value",
        "proplist_key2" => "proplist_value2"
      },
      "some_atom",
      '<<"some_binary">>'
    ]
  },
  "app_b" => {
   "some_key" => 88
  }
}

file '/tmp/expect/erlang.config' do
  content erlang_config(erlang_hash)
end

file '/tmp/expect/erlang.config.expect' do
  content %Q$
    [
      { app_a,
        [
          { atom_key,
            [
              { hash_value_key, "string value" },
              { hash_value_key2, <<"binary value">> }
            ]
          },
          { another_key,
            [
              [
                { proplist_key, proplist_value },
                { proplist_key2, proplist_value2 }
              ],
              some_atom,
              <<"some_binary">>
            ]
          }
        ]
      },
      { app_b,
        [
          { some_key, 88 }
        ]
      }
    ].
  $.strip.gsub(/^    /, '')
end


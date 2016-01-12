module Configuration
  require 'shellwords'
  require 'yaml'
  require 'json'
  require 'erb'

  def desymbol obj
    if obj.is_a? Hash
      Hash[
        obj.map do |k,v|
          [ k.to_s, desymbol(v) ]
        end
      ]
    elsif obj.is_a? Array
      obj.map { |i| desymbol i }
    elsif obj.is_a? Symbol
      obj.to_s
    else
      obj
    end
  end

  def deep_hash obj
    obj.inject({}) do |h, (k,v)|
      h[k] = v.kind_of?(Hash) ? deep_hash(v) : v ; h
    end
  end

  def inline_config obj
    obj['lines'].join("\n") + "\n"
  end

  def yaml_config obj
    deep_hash(obj).to_yaml.strip
  end

  def hocon_config obj
    begin
      ::Hocon
    rescue NameError # Cute trick to install the gem at runtime
      r = Chef::Resource::ChefGem.new 'hocon', run_context
      r.run_action :install
      require 'hocon/config_value_factory'
    end
    ::Hocon::ConfigValueFactory.from_map(desymbol(obj)).render
  end

  def properties_config obj
    begin
      ::JavaProperties
    rescue NameError # Cute trick to install the gem at runtime
      r = Chef::Resource::ChefGem.new 'java-properties', run_context
      r.run_action :install
      require 'java-properties'
    end
    ::JavaProperties.generate obj
  end

  def json_config obj
    ::JSON.pretty_generate obj
  end

  def exports_raw_config obj
    obj.map do |k, v|
      "export #{k}=#{Shellwords.escape v.to_s}"
    end.join("\n")
  end

  def exports_config obj, header=nil
    obj.map do |k, v|
      if v.nil?
        k.to_s
      else
        "export #{k}=#{Shellwords.escape v.to_s}"
      end
    end.join("\n")
  end

  def toml_config obj
    begin
      ::TOML
    rescue NameError # Cute trick to install the gem at runtime
      r = Chef::Resource::ChefGem.new 'toml', run_context
      r.run_action :install
      require 'toml'
    end
    TOML::Generator.new(obj).body
  end

  def ini_config obj
    obj.map do |name, config|
      "[#{name}]\n" + \
      config.map do |k, v|
        "#{k}=#{v}"
      end.join("\n")
    end.join("\n\n")
  end

  def java_config obj, l=0
    if obj.is_a? Hash
      result = []
      len = obj.keys.length
      obj.keys.each_with_index do |k,i|
        v = obj[k]
        r = if v.is_a? Hash
          "#{'  '*l}#{k} {\n#{java_config(v, l+1)}\n#{'  '*l}}\n"
        else
          "#{'  '*l}#{k} = #{java_config(v)}"
        end
        r.rstrip! if i == len - 1
        result << r
      end
      result.join("\n")

    elsif obj.is_a? Array
      objs = obj.map { |o| java_config(o, l+1) }
      '[ %s ]' % objs.join(', ')

    elsif obj.is_a? Symbol
      obj.to_s

    else
      obj.inspect
    end
  end

  def erlang_config obj
    config = erlang_hash_to_proplist obj
    config += "."
  end

  def erlang_array_config config_array, indent = 0
    config_string = "#{make_indent indent}[\n"
    config_item_strings = []
    config_array.each do | config_item |
      config_item_strings << erlang_array_item_config(config_item, indent + 1)
    end
    config_string += config_item_strings.join(",\n")
    config_string += "\n#{make_indent indent}]"
  end

  def erlang_array_item_config config, indent = 0
    if config.is_a? Hash
      erlang_hash_to_proplist config, indent
    elsif config.is_a? Array
      erlang_array_config config, indent
    else
      "#{make_indent indent}#{config}"
    end
  end

  def erlang_hash_to_proplist config, indent = 0
    key_config = "#{make_indent indent}[\n"
    configs = []
    config.each do | config_key, config_value |
      configs << erlang_key_config(config_key, config_value, indent + 1)
    end
    key_config += configs.join(",\n")
    key_config += "\n#{make_indent indent}]"
  end

  def erlang_key_config key, config, indent = 0
    if config.is_a? Hash
      key_config = "#{make_indent indent}{ #{key},\n"
      key_config += erlang_hash_to_proplist(config, indent + 1)
      key_config += "\n#{make_indent indent}}"
    elsif config.is_a? Array
      key_config = "#{make_indent indent}{ #{key},\n"
      key_config += erlang_array_config(config, indent + 1)
      key_config += "\n#{make_indent indent}}"
    else
      "#{make_indent indent}{ #{key}, #{config} }"
    end
  end

  def make_indent indent
    "  " * indent
  end

  def quote_logstash obj
    case obj.class.to_s
    when /Array/
      '[ %s ]' % obj.map { |c| quote_logstash c }.join(', ')
    when /Regexp/
      "'%s'" % obj.to_s
    when /Symbol/
      obj.to_s
    when /TrueClass/
      'true'
    when /FalseClass/
      'false'
    else
      obj.inspect.gsub('\\\\', '\\')
    end
  end

  def logstash_typed_config obj
    tpl = %Q$
      input {
      <% obj['input'].each do |type, inputs| %>
      <% inputs.each do |name, config| %>
        <%= name %> {<% config.each do |k, v| %>
          <%= k %> => <%= quote_logstash v %><% end %>
          <% if type.is_a?(String) %>type => <%= quote_logstash type %><% end %>
        }
      <% end %><% end %>
      }

      filter {
      <% obj['filter'].each do |type, filters| %>
        <% type = type.strip if type.is_a?(String) %>
        <% if type.is_a?(String) && type =~ /^(if|else)/ %><%= type %> {
        <% elsif type.is_a?(String) %>if [type] == <%= quote_logstash type %> {<% end %>
        <% filters.each do |name, config| %>
          <% if name.is_a?(String) && name =~ /^(if|else)/ %>
          <%= name %> {<%= "\n" if config.keys.empty? %><% config.each do |k, v| %>
            <%= k %> {<%= "\n" if config[k].keys.empty? %><% config[k].each do |k2, v2| %>
              <%= k2 %> => <%= quote_logstash v2 %><% end %>
            }<% end %>
          }
          <% elsif name.is_a?(String) %>
          <%= name %> {<%= "\n" if config.keys.empty? %><% config.each do |k, v| %>
            <%= k %> => <%= quote_logstash v %><% end %>
          }
          <% else %>
            <%= quote_logstash config %>
          <% end %>
      <% end %><% if type.is_a?(String) %>  }
      <% end %><% end %>
      }

      output {
      <% obj['output'].each do |type, outputs| %>
        <% if type.is_a?(String) && type =~ /^(if|else)/ %><%= type %> {
        <% elsif type.is_a?(String) %>if [type] == <%= quote_logstash type %> {<% end %>
        <% outputs.each do |name, config| %>
          <%= name %> {<% config.each do |k, v| %>
            <%= k %> => <%= quote_logstash v %><% end %>
          }
      <% end %><% if type.is_a?(String) %>  }
      <% end %><% end %>
      }
    $.strip.gsub(/^      /, '')
    ERB.new(tpl).result(binding).gsub(/(\n\s*)+?\n/, "\n")
  end
end

class Chef
  class Recipe
    include Configuration
  end
end

class Chef
  class Resource
    include Configuration
  end
end

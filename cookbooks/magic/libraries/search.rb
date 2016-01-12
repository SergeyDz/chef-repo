module Search
  def ip_to_i ip
    ip.split('.').map do |i|
      '%03d' % i.to_i
    end.join('').to_i
  end

  def search_realm params
    params = { chef_environment: node.environment }.merge params
    search_nodes params
  end

  def search_nodes params
    nodes = []
    exclude_self = params.delete(:exclude_self)
    search(:node, search_nodes_query(params)) do |n|
      next if exclude_self and n.name == node.name
      nodes << n if n['ipaddress']
    end
    return nodes.sort_by { |n| ip_to_i n['ipaddress'] }
  end

  def search_nodes_query params
    join_with   = params.delete(:join_with)
    join_with ||= 'AND'
    return params.map do |k, v|
      '%s:%s' % [ k, v ]
    end.join(" #{join_with} ")
  end
end

class Chef
  class Recipe
    include ::Search
  end
end

class Chef
  class Resource
    include ::Search
  end
end
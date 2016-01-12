require 'shellwords'

module Helpers
  def file_cache_path *fp
    if fp.nil?
      Chef::Config[:file_cache_path]
    else
      ::File.join Chef::Config[:file_cache_path], *fp
    end
  end

  def resource? name
    begin
      resources name
    rescue Chef::Exceptions::ResourceNotFound
      nil
    end
  end

  def shell_opts opts
    opts.map do |k, v|
      case v
      when true ; "--#{k}"
      when false ; nil
      else
        "--#{k} #{Shellwords.escape v.to_s}"
      end
    end.compact.join(' ')
  end

  def upstart_opts opts
    opts.map do |k, v|
      case v
      when true ; "--#{k}"
      when false ; nil
      else
        "--#{k} '#{v}'"
      end
    end.compact.join(' ')
  end
end

class Chef
  class Recipe
    include Helpers
  end
end

class Chef
  class Resource
    include Helpers
  end
end
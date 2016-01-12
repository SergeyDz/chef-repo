module DeepMerge

  # Cribbed from Ruby on Rails: http://apidock.com/rails/Hash/deep_merge
  # File activesupport/lib/active_support/core_ext/hash/deep_merge.rb, line 16
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  # Cribbed from Ruby on Rails: http://apidock.com/rails/Hash/deep_merge%21
  # File activesupport/lib/active_support/core_ext/hash/deep_merge.rb, line 21
  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |current_key, other_value|
      this_value = self[current_key]

      self[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
        this_value.deep_merge(other_value, &block)
      else
        if block_given? && key?(current_key)
          block.call(current_key, this_value, other_value)
        else
          other_value
        end
      end
    end

    self
  end

end


class Hash
  include DeepMerge
end
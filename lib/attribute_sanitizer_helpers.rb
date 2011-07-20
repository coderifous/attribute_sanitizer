class AttributeSanitizer
  module Helpers

    # When called with a block this will instantiate a new AttributeSanitizer and
    # call the block using instance_eval.  The DSL methods for sanitizing
    # attributes may be called inside of the block.
    #
    # Example:
    #
    # class Foo
    #   include AttributeSanitizer::Helpers
    #
    #   sanitize_attributes do
    #     remap :bagel => :bagels
    #     remap :bagels => :bagels_attributes
    #     ensure_array :bagels_attributes
    #   end
    # end
    #
    # Subsequently calling this method with a hash will apply the sanitization
    # steps, in the order declared, sanitizing the hash.
    #
    # attrs = { :bagel => { :flavor => "blueberry" } }
    #
    # Foo.sanitize_attributes(attrs)
    #
    # attrs # => { :bagels_attributes => [ { :flavor => "blueberry" } ] }
    #
    # You can also pass a non-hash value.  The steps for sanitization must know
    # what to do with whatever you pass in.  Here's an example using a custom
    # defined step:
    #
    # class Foo
    #   sanitize_attributes do
    #     add_step :split_on_commas # bad example
    #   end
    #
    #   def self.split_on_commas(val)
    #     if val.is_a?(String)
    #       val.split(",")
    #     else
    #       val
    #     end
    #   end
    # end
    #
    # Foo.sanitize_attributes("1,2,3") # => ["1", "2", "3"]
    def sanitize_attributes(attrs=nil, &block)
      if attrs
        return attrs unless @_attribute_sanitizer
        @_attribute_sanitizer.sanitize(attrs)
      elsif block_given?
        @_attribute_sanitizer = AttributeSanitizer.new(self)
        @_attribute_sanitizer.instance_eval(&block)
      else
        raise "sanitize_attributes needs an argument"
      end
    end

  end
end

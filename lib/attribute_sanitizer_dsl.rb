require 'active_support/inflector'
require "active_support/core_ext/string"

class AttributeSanitizer
  module DSL

    # Adds a step to the sanitization routine.
    #
    # If passed a block, that block is added as a step.
    #
    # If passed a symbol or string, then a custom step will be added that calls
    # that method on the method_delegate (typically your class).
    def add_step(method=nil, &block)
      if block_given?
        sanitization_steps << block
      elsif method
        add_step { |attrs| method_delegate.send(method, attrs) }
      end
    end

    # Adds a step that renames a hash key.
    #
    # @parameter [Hash] describing the remap action
    #
    # @example
    #   remap :foo => :bar
    def remap(mapping)
      from = mapping.keys.first
      to   = mapping[from]
      add_step do |attrs|
        attrs[to] = attrs.delete(from) if attrs.has_key?(from)
        attrs
      end
    end

    # Adds a step that ensures that a hash value is an array
    #
    # @parameter [Object] the key whose value we want to be an array
    #
    # @example
    #   ensure_array :bagels_attributes
    def ensure_array(field)
      add_step do |attrs|
        if attrs.has_key?(field) && !attrs[field].is_a?(Array)
          attrs[field] = [attrs[field]]
        end
        attrs
      end
    end

    # Adds a step that iterates over items in array and calls sanitize_attributes
    # using the specified class.
    #
    # @parameter [Hash] descriping the field and class
    #
    # @example
    #   sanitize_nested_attributes :bagels_attributes => Bagel
    def sanitize_nested_attributes(mapping)
      key   = mapping.keys.first
      klass = mapping[key]
      add_step do |attrs|
        if attrs.has_key?(key)
          attrs[key].compact!
          attrs[key].map! { |val| klass.sanitize_attributes(val) }
        end
        attrs
      end
    end

    # Adds several steps that can be useful when dealing with
    # accepts_nested_attributes_for in Rails projects.
    #
    # @parameter [Object] association name
    #
    # @example
    #   sanitize_has_many :bagels
    #
    # This is equivalent to:
    #   remap :bagel => :bagels_attributes
    #   remap :bagels => :bagels_attributes
    #   ensure_array :bagels_attributes
    #   sanitize_nested_attributes :bagels_attributes => Bagel
    def sanitize_has_many(association_name)
      association_name = association_name.to_s
      singular_name    = association_name.singularize
      nested_name      = "#{association_name}_attributes"
      klass            = association_name.singularize.camelize.constantize
      remap singular_name    => nested_name
      remap association_name => nested_name
      ensure_array nested_name
      sanitize_nested_attributes nested_name => klass
    end
  end
end

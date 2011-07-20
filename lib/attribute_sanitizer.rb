require 'active_support'
require "attribute_sanitizer_helpers"
require "attribute_sanitizer_dsl"

class AttributeSanitizer
  attr_accessor :sanitization_steps, :method_delegate
  include DSL

  def initialize(method_delegate)
    self.sanitization_steps = []
    self.method_delegate = method_delegate
  end

  # Applies sanitization steps to provided ata.
  #
  # @param [Object] the data to be sanitized
  #
  # @return [Object] the sanitized data
  def sanitize(attrs)
    sanitization_steps.inject(attrs) { |new_attrs, step| step.call(new_attrs) }
  end
end


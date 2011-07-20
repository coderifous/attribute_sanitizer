$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "lib")

require 'test/unit'
require 'shoulda'
require 'mocha'
require 'attribute_sanitizer'

class Bagel
  extend AttributeSanitizer::Helpers
end

class TestAttributeSanitizer < Test::Unit::TestCase
  def setup
    @sanitizer = AttributeSanitizer.new(self)
  end

  context "#sanitize with no steps" do
    should "do nothing" do
      sanitized = @sanitizer.sanitize("foo")
      assert_equal "foo", sanitized
    end
  end

  context "#add_steps with a block" do
  end

  context "#add_steps" do
    should "add named method as a step" do
      @sanitizer.add_step :stringify
      assert_equal "1", @sanitizer.sanitize(1)
    end

    should "add block as a step" do
      @sanitizer.add_step { |val| val.to_i }
      assert_equal 1, @sanitizer.sanitize("1")
    end
  end

  context "#remap" do
    should "rename a hash key" do
      @sanitizer.remap :foo => :bar
      assert_equal({ bar: 1 }, @sanitizer.sanitize(foo: 1))
    end
  end

  context "#ensure_array" do
    setup do
      @sanitizer.ensure_array :foo
    end

    should "wrap a non-array value in array" do
      assert_equal({ foo: [1] }, @sanitizer.sanitize(foo: 1))
    end

    should "not wrap array value in array" do
      assert_equal({ foo: [1] }, @sanitizer.sanitize(foo: [1]))
    end

    should "not mess with nested arrays" do
      assert_equal({ foo: [[1,2], [3, 4]] }, @sanitizer.sanitize(foo: [[1,2], [3,4]]))
    end
  end

  context "#sanitize_nested_attributes" do
    setup do
      @sanitizer.sanitize_nested_attributes :foos_attributes => Bagel
    end

    should "iterate over elements and call sanitize_attributes on each one with given class" do
      Bagel.expects(:sanitize_attributes).times(3)
      @sanitizer.sanitize(foos_attributes: [1,2,3])
    end
  end

  context "#sanitize_has_many" do
    setup do
      @sanitizer = AttributeSanitizer.new(Bagel)
    end
    should "add steps to for sanitizing nested attributes for the typical has many association" do
      @sanitizer.expects(:remap).with("bagel"  => "bagels_attributes")
      @sanitizer.expects(:remap).with("bagels" => "bagels_attributes")
      @sanitizer.expects(:ensure_array).with("bagels_attributes")
      @sanitizer.expects(:sanitize_nested_attributes).with("bagels_attributes" => Bagel)
      @sanitizer.sanitize_has_many :bagels
    end
  end

  context "#sanitize_attributes" do
    should "let us add sanitization steps and also run sanitization steps on input" do
      Bagel.sanitize_attributes do
        remap :foo => :bar
      end
      assert_equal({bar: 1}, Bagel.sanitize_attributes(foo: 1))
    end
  end

  def stringify(val)
    val.to_s
  end
end

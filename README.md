AttributeSanitizer - DSL for specifiying steps to sanitize input.
=================================================================

Example
-------

    class Foo
      include AttributeSanitizer::Helpers

      sanitize_attributes do
        remap :bagel => :bagels
        remap :bagels => :bagels_attributes
        ensure_array :bagels_attributes
      end
    end

Subsequently calling this method with a hash will apply the sanitization
steps, in the order declared, sanitizing the hash.

    attrs = { :bagel => { :flavor => "blueberry" } }

    Foo.sanitize_attributes(attrs)

    attrs # => { :bagels_attributes => [ { :flavor => "blueberry" } ] }

You can also pass a non-hash value.  The steps for sanitization must know
what to do with whatever you pass in.  Here's an example using a custom
defined step:

    class Foo
      sanitize_attributes do
        add_step :split_on_commas # bad example
      end

      def self.split_on_commas(val)
        if val.is_a?(String)
          val.split(",")
        else
          val
        end
      end
    end

    Foo.sanitize_attributes("1,2,3") # => ["1", "2", "3"]

Why?
----

I created this for a project where I had to deal with input that didn't
quite conform to my models, and I didn't want to change the API of my
application to facilitate non-conforming inputs.

License
-------

AttributeSanitizer is Copyright © 2011 Jim Garvin. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.


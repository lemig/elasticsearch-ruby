module Elasticsearch
  module DSL
    module Search

      # Contains the classes for Elasticsearch aggregations
      #
      module Aggregations;end

      # Wraps the `aggregations` part of a search definition
      #
      # @see http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-aggregations.html
      #
      class Aggregation
        def initialize(*args, &block)
          @block = block
        end

        def call
          @block.arity < 1 ? self.instance_eval(&@block) : @block.call(self) if @block
          self
        end

        # Looks up the corresponding class for a method being invoked, and initializes it
        #
        # @raise [NoMethodError] When the corresponding class cannot be found
        #
        def method_missing(name, *args, &block)
          klass = name.capitalize
          if Aggregations.const_defined? klass
            # if @value
            #   @value = [ @value ] unless @value.is_a?(Array)
            #   @value << Aggregations.const_get(klass).new(*args, &block)
            # else
              @value = Aggregations.const_get(klass).new *args, &block
            # end
          else
            raise NoMethodError, "undefined method '#{name}' for #{self}"
          end
        end

        # Evaluates any block passed to the query
        #
        # @return [self]
        #
        def call
          @block.arity < 1 ? self.instance_eval(&@block) : @block.call(self) if @block && ! @_block_called
          @_block_called = true
          self
        end

        # Converts the query definition to a Hash
        #
        # @return [Hash]
        #
        def to_hash(options={})
          call

          if @value
            case
              when @value.respond_to?(:to_hash)
                @value.to_hash
              when @value.respond_to?(:map)
                @value.map { |f| f.to_hash }
              else
                @value
            end
          else
            {}
          end
        end
      end

    end
  end
end

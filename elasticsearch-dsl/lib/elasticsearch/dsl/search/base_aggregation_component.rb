module Elasticsearch
  module DSL
    module Search

      # Module containing common functionality for DSL classes
      #
      module BaseAggregationComponent

        def self.included(base)
          base.__send__ :include, InstanceMethods
        end

        module InstanceMethods

          # Looks up the corresponding class for a method being invoked, and initializes it
          #
          # @raise [NoMethodError] When the corresponding class cannot be found
          #
          def method_missing(name, *args, &block)
            klass = name.capitalize
            if Aggregations.const_defined? klass
              @value = Aggregations.const_get(klass).new *args, &block
            else
              raise NoMethodError, "undefined method '#{name}' for #{self}"
            end
          end

          def aggregation(*args, &block)
            @aggregations ||= {}
            @aggregations.update args.first => Aggregation.new(*args, &block)
            self
          end

          # Convert the aggregations to a Hash
          #
          # A default implementation, DSL classes can overload it.
          #
          # @return [Hash]
          #
          def to_hash(options={})
            call

            @hash = { name => @args } unless @hash && @hash[name]

            if @aggregations
              @hash[:aggregations] = {}
              @aggregations.map { |name, value| @hash[:aggregations][name] = value.to_hash }
            end
            @hash
          end
        end

      end

    end
  end
end


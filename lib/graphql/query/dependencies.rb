module GraphQL
  class Query
    class Dependencies
      def initialize(query)
        @query = query
        @storage = {}
      end

      # Batch a value for `resolve`, we'll call it later and
      # it will pass success / failure to `handler`.
      #
      # @param resolver [<#dependency_key, #resolve(objs, ctx, responder)> ]
      # @param value [Object]
      # @param handler [<#fulfill(value), #reject(value)>]
      def register(resolver, value, handler)
        batch_key = resolver.dependency_key
        codep_values = @storage[batch_key] ||= CodependentValues.new(resolver)
        codep_values.register(value, handler)
      end


      # Find each batch and resolve it
      def resolve_pending
        @storage.each do |key, codep_values|
          codep_values.each do |codep|
            codep.resolve(query)
          end
        end
      end

      private

      class CodependentValues
        def initialize(resolver)
          @resolver = resolver
          @storage = {}
        end

        def register(value, handler)
          @storage[value] = handler
        end

        def resolve(query)
          responder = ResolveResponder.new(@storage)
          resolver.resolve(@storage.keys, query.context, responder)
        end
      end

      class ResolveResponder
        def initialize(pending_values)
          @pending_values = pending_values
        end

        # TODO handle nonsense keys
        def fulfill(key, value)
          @pending_values[key].fulfill(value)
        end

        def reject(key, value)
          @pending_values[key].reject(values)
        end
      end
    end
  end
end

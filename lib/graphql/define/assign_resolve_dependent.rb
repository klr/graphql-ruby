module GraphQL
  module Define
    module AssignResolveDependent
      def self.call(field, resolver, resolve_func)
        dependent_resolve = GraphQL::Query::Dependent::DependentResolve.new(resolver, resolve_func)
        field.resolve = dependent_resolve
      end
    end
  end
end

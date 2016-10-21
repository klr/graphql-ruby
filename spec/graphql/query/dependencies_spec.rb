require "spec_helper"

module DependenciesHelper
  class ArrayLoader
    attr_reader :items

    def initialize
      @items = []
    end

    def push(item, &block)
      @items << item
      Dependency.new(item, block)
    end

    def resolve(items, query, respond)
      items.each do |item|
        item.fulfill(items)
      end
    end

    def dependency_key
      "items"
    end

    class Dependency
      attr_reader :key
      def initialize(key, fulfill)
        @key = key
        @fulfill = fulfill
      end

      def promise
        self
      end

      def fulfill(value)
        @fulfill.call(value)
      end
    end
  end

  QueryType = GraphQL::ObjectType.define do
    name "Query"
    field :push, types[types.Int] do
      argument :int, !types.Int
      resolve_dependent ArrayLoader.new, -> (loader, obj, args, ctx) {
        loader.push(args[:int]) { |items| items }
      }
    end
  end

  Schema = GraphQL::Schema.define do
    query QueryType
  end

  def exec_query(query_string)
    Schema.execute(query_string)
  end
end

describe GraphQL::Query::Dependencies do
  include DependenciesHelper

  describe "A simple batching system" do
    let(:query_string) { %|
      {
        p1: push(int: 1)
        p2: push(int: 2)
        p3: push(int: 3)
      }
    |}

    it "returns the fulfilled value" do
      pp exec_query(query_string)
    end
  end
end

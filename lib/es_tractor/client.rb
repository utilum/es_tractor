# frozen_string_literal: true
require 'elasticsearch'

module EsTractor
  ##
  # Client provides an Elasticsearch::Client with a limited subset of
  # methods and simplified arguments.
  class Client
    # @example
    #   'my_index'
    ELASTICSEARCH_INDEX = ENV['ES_TRACTOR_ELASTICSEARCH_INDEX']

    # @example
    #   'example.com:9200'
    ELASTICSEARCH_HOST = ENV['ES_TRACTOR_ELASTICSEARCH_HOST']

    # @attr_reader [Elasticsearch::Client] client to search with.
    attr_reader :client

    # @param [true, false] log verbose output of client-server interactions
    def initialize(log = false)
      @client = Elasticsearch::Client.new(
        host: ELASTICSEARCH_HOST,
        log: log,
      )
    end

    # Count documents, filtered by options.
    # @return [Hash] with the result in the 'count' key.
    # @param [Hash] opts with the following keys:
    # @option opts [String, Array<String>] :exists
    #   One or more field names, translated into filter boolean.
    # @option opts [Hash, Array<Hash>] :match
    #   One or more field: match pairs, translated into must boolean.
    # @option opts [Hash, Array<Hash>] :term
    #   One or more field: term pairs, translated into a filter boolean.
    # @option opts [Hash<Array>] :range
    #   A hash keyed on a field name, containing an array: [min, max],
    #   translated into a filter boolean.
    #
    # @example
    #   opts = {
    #     match: { color: 'strawberry black' },
    #     exists: ['flavor', 'spicy'],
    #     term: [
    #       { flavor: 'vanilla' },
    #       { spicy: 3 },
    #     ],
    #   }
    #
    #   Client.new.count(opts) # => { 'count' => 7 }
    #
    #   # Tranforms opts into the following hash, passed to Elasticsearch:
    #     {
    #       body:  {
    #         query: {
    #           bool: {
    #             must: {
    #               match: { flavor: 'vanilla' },
    #             },
    #             filter: [
    #               { term: { flavor: 'vanilla' } },
    #               { term: { spicy: 3 } },
    #             ],
    #           },
    #         },
    #       },
    #     }
    def count(opts = {})
      body = body(opts)
      @client.count(body: body)
    end

    # @return [Hash] with the actual result in the 'hits'['hits'] key.
    # @param (see #count)
    # @option (see #count)
    # @option opts [Integer] :from
    # @option opts [Integer] :size
    def search(opts)
      args = {
        from: opts[:from] ? opts[:from] : 0,
        size: opts[:size] ? opts[:size] : 0,
        body: body(opts),
      }
      @client.search(args)
    end

    private

    def array_or_hash(name, filter)
      case filter
      when Array
        filter.map { |f| { name => f } }
      when Hash
        [name => filter]
      else
        []
      end
    end

    def body(opts = {})
      {
        query: query(opts),
      }
    end

    def query(opts = {})
      bool = { filter: [], must: [] }

      (%i[exists match range term] & opts.keys).each do |qualifier|
        case qualifier
        when :exists
          bool[:filter].push(exists: { field: opts[qualifier] })
        when :match
          bool[:must] += array_or_hash(qualifier, opts[:match])
        when :range
          bool[:filter].push(range: range(opts[:range]))
        when :term
          bool[:filter] += array_or_hash(qualifier, opts[:term])
        end
      end

      { bool: bool }
    end

    def range(range_opt)
      {
        range_opt.keys.first => {
          gte: range_opt.values.first.first,
          lte: range_opt.values.first.last,
        },
      }
    end
  end
end

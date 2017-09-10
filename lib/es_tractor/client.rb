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
    # @option opts [String] :query_string
    #   Translated into must boolean.
    # @option opts [Hash<Array>] :range
    #   A hash keyed on a field name, containing an array: [min, max],
    #   translated into filter boolean.
    # @option opts [Hash, Array<Hash>] :term
    #   One or more field: term pairs, translated into filter boolean.
    #
    # @example
    #   opts = {
    #     match: { topping: 'fudge' },
    #     exists: ['address', 'phone'],
    #     term: [
    #       { flavor: 'vanilla' },
    #       { scoops: 3 },
    #     ],
    #   }
    #
    #   Client.new.count(opts) # => { 'count' => 7 }
    #
    #   # Tranforms opts into the following hash, passed to Elasticsearch:
    #   {
    #     "query": {
    #       "bool": {
    #         "filter": [
    #           { "exists": { "field": ["address", "phone"] } },
    #           { "term": { "flavor": "vanilla" } },
    #           { "term":{ "scoops": 3 } }
    #         ],
    #         "must": [
    #           { "match": { "topping": "fudge" } }
    #         ]
    #       }
    #     }
    #   }
    def count(opts = {})
      args = { body: body(opts) }
      @client.count(args)
    end

    # Search documents, filtered by options, aggregate on special
    # aggregations keys.
    #
    # Supported aggregations (avg, cardinality, extended_stats, geo_bounds,
    # geo_centroid, max min, percentiles, stats, sum, value_count) take
    # a field name and are automatically named.
    # @example
    #   opts = {
    #     query_string: 'flavor:vanilla AND cone:true',
    #     avg: "scoops",
    #   }
    #
    #   Client.new.search(opts)
    #
    #   # Tranforms opts into the following hash, passed to Elasticsearch:
    #   {
    #     "query": {
    #       "bool": {
    #         "filter":[],
    #         "must":[
    #           {
    #             "query_string": {
    #               "query":"flavor:vanilla AND cone:true"
    #             }
    #           }
    #         ]
    #       }
    #     },
    #     "aggs": {
    #       "avg-intelligence": {
    #         "avg": {
    #           "field":"scoops"
    #         }
    #       }
    #     }
    #   }
    #
    # @return [Hash] with the actual results in the <tt>'hits'['hits']</tt>
    #   key.
    #
    # @param (see #count)
    # @option (see #count)
    # @option opts [Integer] :from
    # @option opts [Integer] :size
    # @option opts [String] :avg
    #   Field name on which to apply the avg aggregation
    # @option opts [String] :cardinality
    #   Field name on which to apply the cardinality aggregation
    # @option opts [String] :extended_stats
    #   Field name on which to apply the extended_stats aggregation
    # @option opts [String] :geo_bounds
    #   Field name on which to apply the geo_bounds aggregation
    # @option opts [String] :geo_centroid
    #   Field name on which to apply the geo_centroid aggregation
    # @option opts [String] :max
    #   Field name on which to apply the max aggregation
    # @option opts [String] :min
    #   Field name on which to apply the min aggregation
    # @option opts [String] :percentiles
    #   Field name on which to apply the percentiles aggregation
    # @option opts [String] :stats
    #   Field name on which to apply the stats aggregation
    # @option opts [String] :sum
    #   Field name on which to apply the sum aggregation
    # @option opts [String] :value_count
    #   Field name on which to apply the value_count aggregation
    def search(opts)
      args = {
        from: opts[:from] ? opts[:from] : 0,
        size: opts[:size] ? opts[:size] : 0,
        body: body(opts),
      }
      @client.search(args)
    end

    private

    def supported_aggs
      metrics_aggs
    end

    def metrics_aggs
      %i( avg cardinality extended_stats geo_bounds geo_centroid max min
          percentiles stats sum value_count)
    end

    def aggs(opts)
      aggregations = {}
      (supported_aggs & opts.keys).each do |aggregation|
        name = [aggregation, opts[aggregation]].join('-').to_sym
        aggregations[name] = {
          aggregation => { field: opts[aggregation] }
        }
      end
      aggregations
    end

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
      body = { query: query(opts) }
      body[:aggs] = aggs(opts) if (supported_aggs & opts.keys).any?
      body
    end

    def query(opts = {})
      bool = { filter: [], must: [] }

      (%i(exists match query_string range term) & opts.keys)
        .each do |qualifier|
        case qualifier
        when :exists
          bool[:filter].push(exists: { field: opts[qualifier] })
        when :match
          bool[:must] += array_or_hash(qualifier, opts[:match])
        when :query_string
          bool[:must].push(query_string: { query: opts[:query_string] })
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

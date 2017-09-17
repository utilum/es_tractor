# frozen_string_literal: true
require 'elasticsearch'

module EsTractor
  # Query translates a Hash argument into a Hash in Elasticsearchese.
  class Query
    attr_accessor :aggregations, :filters, :musts

    SUPPORTED_AGGREGATIONS = %i(
      avg cardinality extended_stats geo_bounds geo_centroid max min 
      percentiles stats sum value_count
    ).map(&:freeze)
    SUPPORTED_FILTERS = %i(term).map(&:freeze)
    SUPPORTED_MUSTS = %i().map(&:freeze)

    def initialize(opts)
      @aggregations = []
      @filters = []
      @musts = []

      opts[:query_string] = '*' if opts.empty?

      opts.keys.each do |qualifier|
        if SUPPORTED_AGGREGATIONS.include?(qualifier)
          @aggregations.push(agg(qualifier, opts[qualifier]))
        elsif SUPPORTED_FILTERS.include?(qualifier)
          @filters.push(filter(qualifier, opts[qualifier]))
        elsif SUPPORTED_MUSTS.include?(qualifier)
          @musts.push(must(qualifier, opts[qualifier]))
        else
          warn "#{qualifier} is not supported"
        end
      end
    end

    def agg(qualifier, opts)
      { qualifier => opts }
    end

    def filter(qualifier, opts)
      { qualifier => opts }
    end

    def must(qualifier, opts)
      { qualifier => opts }
    end
  end
end

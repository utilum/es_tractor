# frozen_string_literal: true
require 'helper'

module EsTractor
  class TestClient < Test
    def setup
      @tractor = Client.new
    end

    %w[count search].each do |action|
      exp = action == 'search' ? { from: 0, size: 0 } : {}

      define_method "test_#{action}_with_term_hash" do
        opts = { term: { my_field: 'my precise term' } }
        exp[:body] = { query: { bool: {
          must: [],
          filter: [
            term: { my_field: 'my precise term' }
          ],
        } } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      define_method "test_#{action}_with_term_array" do
        opts = { term: [
          { my_field: 'my precise term' },
          { my_other_field: 'my other term' },
        ] }
        exp[:body] = { query: { bool: {
          must: [],
          filter: [
            { term: { my_field: 'my precise term' } },
            { term: { my_other_field: 'my other term' } },
          ],
        } } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      define_method "test_#{action}_with_match_hash" do
        opts = { match: { my_field: 'my match' } }
        exp[:body] = { query: { bool: {
          must: [{ match: { my_field: 'my match' } }],
          filter: [],
        } } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      define_method "test_#{action}_with_range_hash" do
        min = 1
        max = 2
        opts = { range: { my_field: [min, max] } }
        exp[:body] = { query: {
          bool: {
            must: [],
            filter: [
              range: {
                my_field: {
                  gte: min,
                  lte: max,
                },
              },
            ],
          },
        } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      define_method "test_#{action}_with_exists_fieldname_value" do
        opts = { exists: 'my_field' }
        exp[:body] = { query: {
          bool: {
            must: [],
            filter: [
              { exists: { field: 'my_field' } },
            ],
          },
        } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      define_method "test_#{action}_with_exists_fieldname_array" do
        opts = { exists: %w[my_field my_other_field] }
        exp[:body] = { query: {
          bool: {
            must: [],
            filter: [
              {
                exists: {
                  field: %w[my_field my_other_field],
                },
              },
            ],
          },
        } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      define_method "test_#{action}_with_query_string" do
        opts = { query_string: 'My query string' }
        exp[:body] = { query: {
          bool: {
            must: [query_string: { query: 'My query string' }],
            filter: [],
          },
        } }

        @tractor.client.expects(action).with(exp)

        @tractor.send(action, opts)
      end

      next unless action == 'search'

      %i[
        avg cardinality extended_stats geo_bounds geo_centroid max min
        percentiles stats sum value_count
      ].each do |aggregation|
        define_method "test_search_with_#{aggregation}_agg" do
          opts = {
            query_string: 'My query string',
            aggregation => 'grade',
          }
          exp = {
            from: 0,
            size: 0,
            body: {
              query: {
                bool: {
                  must: [query_string: { query: 'My query string' }],
                  filter: [],
                },
              },
              aggs: {
                "#{aggregation}-grade".to_sym => {
                  aggregation => { field: 'grade' }
                },
              },
            },
          }

          @tractor.client.expects(:search).with(exp)

          @tractor.search opts
        end
      end
    end
  end
end

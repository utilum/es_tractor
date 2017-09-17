# frozen_string_literal: true
require 'helper'

module EsTractor
  class TestQuery < Test

    %i(avg cardinality extended_stats geo_bounds geo_centroid max min
      percentiles stats sum value_count).each do |aggregation|

        define_method "test_#{aggregation}_agg" do
    
          query = Query.new(aggregation => { my_field: 'my_term' })
          exp = [{ aggregation => { my_field: 'my_term' } }]

          assert_equal exp, query.aggregations
      end
    end
  end
end

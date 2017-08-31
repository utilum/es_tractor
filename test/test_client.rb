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
    end
  end
end

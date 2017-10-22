# frozen_string_literal: true

require 'helper'

class TestEsTractor < Test
  def test_client
    assert Elasticsearch::Transport::Client, Client.new
  end
end

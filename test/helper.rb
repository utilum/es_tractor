# frozen_string_literal: true

ENV['ESTRACTOR_ENV'] = 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

module EsTractor
  class Client
    ELASTICSEARCH_INDEX = ENV['ES_TRACTOR_TEST_ELASTICSEARCH_INDEX']
    ELASTICSEARCH_HOST = ENV['ES_TRACTOR_TEST_ELASTICSEARCH_HOST']
  end
end

require 'es_tractor'
require 'minitest/autorun'
require 'mocha/setup'

class Test < Minitest::Test
  include EsTractor
end

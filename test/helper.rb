# frozen_string_literal: true
ENV['ESTRACTOR_ENV'] = 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'es_tractor'
require 'minitest/autorun'
require 'mocha/setup'

class Test < Minitest::Test
  include EsTractor
end

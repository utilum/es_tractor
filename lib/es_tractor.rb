# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__) + '/es_tractor'
$LOAD_PATH.unshift File.dirname(__FILE__) \
  unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'client'

##
# EsTractor provides tools to query Elasticsearch

module EsTractor
  VERSION = '0.0.6' # :nodoc:
end

# -*- ruby -*-
# frozen_string_literal: true

require 'rubygems'
require 'hoe'

Hoe.plugin :yard

Hoe.spec 'es_tractor' do
  developer('utilum', 'oz@utilum.com')

  license 'MIT'

  require_ruby_version '~> 2.0'
  extra_deps << ['elasticsearch', '~> 5.0', '>= 5.0.4']

  extra_dev_deps << ['hoe-yard', '~> 0.1', '>=0.1.3']
  extra_dev_deps << ['minitest', '~> 5.10', '>=5.10.3']
  extra_dev_deps << ['mocha', '~> 1.3', '>=1.3.0']
  extra_dev_deps << ['pry', '~> 0.10.4']
end

namespace :es_tractor do
  $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
  require 'es_tractor'

  include EsTractor

  namespace :demo do
    desc 'Count all docuements since forever'
    task :count_all do
      tractor = Client.new
      r = tractor.count
      puts "Found #{r} documents"
    end
  end
end

# vim: syntax=ruby

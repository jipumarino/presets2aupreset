#!/usr/bin/env ruby

require 'active_support/all'
require 'json'
require 'pathname'
require 'plist'
require 'yaml'

require './preset_converter.rb'
Dir['./converters/**/*.rb'].each{ |f| require f }

plugin = ARGV[0]
raise "No plugin specified" if plugin.blank?
klass_name = "#{plugin}PresetConverter".delete(" ")
klass = klass_name.safe_constantize
raise "Missing converter class #{klass_name} for #{plugin}" if klass.nil?
converter = klass.new(plugin)
converter.run

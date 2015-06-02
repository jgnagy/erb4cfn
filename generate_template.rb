#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'digest'
require 'base64'
require 'json'

# specify a layout to generate
layout = ARGV[0]
raise "Missing layout" unless layout

# Allow passing settings for the layouts and snippets via a ENV variable
RUNTIME_SETTINGS = {}

ENV["ERB4CFN_OPTS"] ||= "defaults=true"
ENV["ERB4CFN_OPTS"].split(" ").each do |arg|
  key, value = arg.split("=")
  raise "Missing value for key '#{key}'" unless value
  if value.match /^[Ff]alse$/
    value = false
  elsif value.match /^[Tt]rue$/
    value = true
  elsif value.match /^[0-9]+$/
    value = Integer(value)
  end
  RUNTIME_SETTINGS[key.to_sym] = value
end
RUNTIME_SETTINGS.freeze

# Straight-up ERB parsing
def render(file, options = {})
  params = {}.merge(RUNTIME_SETTINGS)
  params = params.merge(options) # blows up with bad input
  erb_free = ERB.new(
      File.read(File.join(file)).gsub(/^(\t|\s)+<%/, '<%'), 0, "<>"
  ).result(binding)
end

def snippet(name, params = {})
  render(File.join("snippets", "#{name}.json.erb"), params)
end

# Utility method for ensuring proper JSON (either quotes, braces, etc) on processed strings
def q(string)
  string.to_s.match(/^[\[{"].*[\]}"]$/) ? string.to_s : '"' + string.to_s + '"'
end

# Read in our template
output = JSON.parse(render(File.join("layouts", "#{layout}.json.erb")))

# Pretty Print
puts JSON.pretty_generate(output)

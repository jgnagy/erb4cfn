#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'digest'
require 'base64'
require 'json'

# specify a layout to generate
layout = ARGV[0]
raise "Missing layout" unless layout

# Straight-up ERB parsing
def render(file, params = {})
  params = {}.merge(params) # blows up with bad input
  erb_free = ERB.new(
      File.read(File.join(file)).gsub(/^(\t|\s)+<%/, '<%'), 0, "<>"
  ).result(binding)
end

def snippet(name, params = {})
  render(File.join("snippets", "#{name}.json.erb"), params)
end

# Read in our template
output = JSON.parse(render(File.join("layouts", "#{layout}.json.erb")))

# Pretty Print
puts JSON.pretty_generate(output)

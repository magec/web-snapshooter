#!/usr/bin/env ruby
#
# WebSnapShooter
#
# Copyright (C) 2011 Jose Fernandez 
# 
# Based in some code from Mirko Maischberger
#
require 'optparse'
require 'rubygems'
require 'gtk2'
require 'gtkmozembed'
require 'uri'

class WebSnapshooter
  
end

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: web-snapshooter [options]"
  
  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.on("-u", "--uri URI", "The uri you want to take the spanshot from") do |u|
    options[:uri] = u
    begin
      URI.parse(u)
    rescue URI::InvalidURIError
      puts "Invalid uri specified"
    end
  end

  opts.on("-f","--force", "Overwrite output") do |f|
    options[:force] = true
  end

  opts.on("-o", "--output-file FILE", "The output file") do |o|
    options[:output_file] = o
  end

  opts.on("", "--browser-size WIDTHxHEIGHT", "The size of the 'fake' browser that is going to be used to capture the snapshot, if not specified the output size will be used instead") do |bs|
    options[:browser_size] = bs
    options[:output_size] = bs
  end

  opts.on("", "--output-size WIDTHxHEIGHT", "The size of the output file, if not specified the browser size will be used instead") do |os|
    options[:output_size] = os
    options[:browser_size] ||= os 
  end
  
end
option_parser.parse!

if File.stat(options[:output_file].to_s) && ! options[:force]
  puts "The output file already exist, please specify another name or force with -f"
  exit 1
end

if options[:output_size].to_s.empty?
  puts "Error, an output_size has to be specified" 
  puts option_parser.help
  exit 1
end

if options[:uri].to_s.empty?
  puts "Error, no uri specified"
  puts option_parser.help 
  exit 1
end

if options[:output_file].to_s.empty?
  puts "An ouput file has to be specified"
  puts option_parser.help 
  exit 1
end

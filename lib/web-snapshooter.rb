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

# I use a base class cause I want to implement it with two engines (gecko and webkit)
class WebSnapshooter < Gtk::Window
  
  # It receives a hash with the different options
  # :uri          => The uri that is going to be rendered
  # :browser_size => An array with the browser size [width,height]
  # :output_size  => An array with the output size [width,height]
  # :output_file  => The name of the output file (it is going to be rewritten)
  def initialize(options)
    super()
    @options = options
  end

end

class MozSnapshooter < WebSnapshooter
  def initialize(opts)
    super
    self.border_width = 0
    self.resize(@options[:browser_size][0], @options[:browser_size][1])
    Gtk::MozEmbed.set_profile_path(ENV['HOME'] + '.mozilla', 'RubyGecko')
    self << Gtk::MozEmbed.new
    self.child.chrome_mask = Gtk::MozEmbed::ALLCHROME
    self.child.set_size_request(@options[:browser_size][0], @options[:browser_size][1])
    self.child.signal_connect("net_stop") { on_net_stop }
    self.child.location = @options[:uri]
    self.show_all
  end

  def on_net_stop
    Gtk::timeout_add(1000) do
      screenshot
      Gtk.main_quit
    end
  end

  def screenshot
    gdkw = self.child.parent_window
    x, y, width, height, depth = gdkw.geometry
    width -= 16
    pixbuf = Gdk::Pixbuf.from_drawable(nil, gdkw, 0, 0, width, height)
    pixbuf = pixbuf.scale(@options[:output_size][0], @options[:output_size][1], Gdk::Pixbuf::INTERP_HYPER)
    if @options[:output_file].split(".").last == "jpeg" || @options[:output_file].split(".").last == "jpg"
      pixbuf.save(@options[:output_file],"jpeg")
    else
      pixbuf.save(@options[:output_file],"png")
    end
  end
end

def dimensions_to_array(dimension)
  aux = dimension.downcase.split("x").map(&:to_i)
  if aux.size == 2 && aux[0] > 0 && aux[1] > 0
    return aux
  else
    return nil
  end
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
    options[:browser_size] = dimensions_to_array(bs)
    options[:output_size]  = dimensions_to_array(bs)
  end

  opts.on("", "--output-size WIDTHxHEIGHT", "The size of the output file, if not specified the browser size will be used instead") do |os|
    options[:output_size] = dimensions_to_array(os)
    options[:browser_size] ||= dimensions_to_array(os)
  end
  
end
option_parser.parse!

begin
  if File.stat(options[:output_file].to_s) && ! options[:force]
    puts "The output file already exist, please specify another name or force with -f"
    exit 1
  end
rescue Errno::ENOENT
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

Gtk.init
MozSnapshooter.new(options)
Gtk.main



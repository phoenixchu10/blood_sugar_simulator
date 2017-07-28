#!/usr/bin/env ruby

require 'active_support/all'
require 'csv'
require File.join File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'simulator'
require File.join File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'concerns', 'record_methods'
require File.join File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'exercise'
require File.join File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'food'
require File.join File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'record'

Food.load
Exercise.load
simulator = Simulator.new

simulator.add_food('12:00' => Food.find(1))
simulator.add_food('13:00' => Food.find(2))

simulator.add_food('14:30' => Food.find(1))
simulator.add_exercise('15:30' => Exercise.find(1))

puts "Whole day blood suguar simulation:"
puts simulator.print_result
puts "----------------------------------"
puts "Glycation: #{simulator.total_glycation} minutes"

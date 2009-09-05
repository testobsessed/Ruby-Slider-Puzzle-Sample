# Written by Elisabeth Hendrickson, Quality Tree Software, Inc.
# Copyright (c) 2009 Quality Tree Software, Inc.
#
# This work is licensed under the 
# Creative Commons Attribution 3.0 United States License.
#
# To view a copy of this license, visit 
#      http://creativecommons.org/licenses/by/3.0/us/
#
# or send a letter to:
#      Creative Commons
#      171 Second Street
#      Suite 300
#      San Francisco, California, 94105
#      USA.

require 'rubygems'
require 'spec'
require 'puzzle'
require 'pp'
require 'permutations'

def stringify(board)
  board_as_string = "["
  board.each{|item|
    if !item.nil?
      board_as_string = board_as_string + " #{item},"
    else
      board_as_string = board_as_string + " blank,"
    end
  }
  board_as_string = board_as_string.chop + " ]"
  return board_as_string
end

permutations = permute([1,2,3,4,5,6,7,8,nil])
num_possibilities = permutations.length
per_start = rand(num_possibilities - 10000)
per_end = per_start + 9999
sample = permutations[per_start..per_end]

puts "There are #{num_possibilities} permutations of the starting board. Sampling #{sample.length} of the permutations starting at location #{per_start}, ending at #{per_end}."

describe "puzzle solve algorithm" do
  
  before(:each) do
    @puzzle = Puzzle.new
  end

  sample.each{ |board| 
    it "should be able to solve [#{stringify(board)}]" do
        @puzzle.load(board)
        @puzzle.solve
        @puzzle.solved?.should be_true
    end
  }
end



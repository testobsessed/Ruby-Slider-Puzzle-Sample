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
require 'permutations'
require 'pp'

describe "permutations" do
  it "should be able to give the 2 permutations for an array of length 2" do
    permute([1,2]).sort.should == [[1,2], [2,1]]
  end
  
  it "should be able to give the 6 permutations for an array of length 3" do
    permute([1,2,3]).sort.should == [
      [1,2,3],
      [1,3,2],
      [2,1,3],
      [2,3,1],
      [3,1,2],
      [3,2,1]
    ]
  end
  
  it "should be able to give the 24 permutations for an array of length 4" do
    permute([1,2,3,4]).sort.should == [
      [1,2,3,4],
      [1,2,4,3],
      [1,3,2,4],
      [1,3,4,2],
      [1,4,2,3],
      [1,4,3,2],
      [2,1,3,4],
      [2,1,4,3],
      [2,3,1,4],
      [2,3,4,1],
      [2,4,1,3],
      [2,4,3,1],
      [3,1,2,4],
      [3,1,4,2],
      [3,2,1,4],
      [3,2,4,1],
      [3,4,1,2],
      [3,4,2,1],
      [4,1,2,3],
      [4,1,3,2],
      [4,2,1,3],
      [4,2,3,1],
      [4,3,1,2],
      [4,3,2,1]
    ]
  end
  
  it "should be able to give the buhzillion permutations for an array of lenght 9 in a reasonable time" do
    variations = permute([1,2,3,4,5,6,7,8,9])
    variations.include?([9,8,7,6,5,4,3,2,1]).should be_true
  end
end
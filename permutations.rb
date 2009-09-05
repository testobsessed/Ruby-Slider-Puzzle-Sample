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

def permute(thing)
  permutations = Array.new
  all_elements = thing
  if (thing.length == 2)
    permutations.push([thing[0], thing[1]])
    permutations.push([thing[1], thing[0]])
  else
    thing.length.times {|n|
      remainder = thing.clone
      building_array = [thing[n]]
      remainder.delete(thing[n])
      variations = permute(remainder)
      variations.each {|variation|
        permutations.push(building_array + variation)
      }
    }
  end
  return permutations
end
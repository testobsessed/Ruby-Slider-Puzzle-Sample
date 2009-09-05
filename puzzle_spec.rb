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

describe "puzzle solving" do
  
  before(:each) do
    @puzzle = Puzzle.new
  end

  it "has 9 elements in a 3x3 grid" do
    @puzzle.board.length.should equal(9)
    @puzzle.board.keys.sort.should == [[1,1], [1,2], [1,3], [2,1], [2,2], [2,3], [3,1], [3,2], [3,3]]
  end
  
  it "loads an array of numbers & populates the grid with it" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.board.should == solved_puzzle
  end
  
  it "raises an error if asked to load an invalid array" do
    lambda {@puzzle.load([1])}.should raise_error("Invalid length: must call with an Array of 9 items.")
  end
  
  it "raises an error if asked to load something that is not an array" do
    lambda {@puzzle.load("a string")}.should raise_error("Invalid type: must call with an Array of 9 items.")
  end
  
  it "knows what moves are legal within the grid" do
    @puzzle.can_move?([1,1], [1,2]).should be_true
  end
  
  it "knows what moves are NOT legal within the grid" do
    @puzzle.can_move?([2,1], [1,2]).should be_false
    @puzzle.can_move?([1,3], [3,3]).should be_false
  end
  
  it "knows whether or not a cell is empty" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.is_empty?([1,1]).should be_false
    @puzzle.is_empty?([3,3]).should be_true
  end
  
  it "only says a move is valid if the cell is empty" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.can_move?([1,1], [1,2]).should be_false
    @puzzle.can_move?([2,3], [3,3]).should be_true
  end
  
  it "knows when two cells are on the same row" do
    @puzzle.same_row?([1,1], [1,2]).should be_true
    @puzzle.same_row?([2,1], [1,2]).should be_false
  end
  
  it "knows when two cells are in the same column" do
    @puzzle.same_column?([1,1], [1,2]).should be_false
    @puzzle.same_column?([1,1], [2,1]).should be_true
  end
  
  it "knows when the puzzle has been solved" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.solved?.should be_true
  end
  
  it "knows when the puzzle has not been solved" do
    @puzzle.load([1, 5, 3, 4, 2, 6, 7, 8, nil])
    @puzzle.solved?.should be_false
  end
  
  it "knows how to make a move" do
    @puzzle.load([1, nil, 3, 4, 2, 6, 7, 8, 5])
    @puzzle.move([1,1], [1,2])
    @puzzle.board[[1,1]].should be_nil
    @puzzle.board[[1,2]].should equal(1)
  end
  
  it "raises an exception on an attempt to make an invalid move" do
    @puzzle.load([1, 5, 3, 4, 2, 6, 7, 8, nil])
    lambda {@puzzle.move([1,1], [1,2])}.should raise_error("Invalid move attempted. Cannot move from [1, 1] to [1, 2].")
  end
  
  it "knows which cell is empty" do
    @puzzle.load([1, 5, 3, 4, 2, 6, 7, 8, nil])
    @puzzle.empty_cell.should == [3,3]
  end
  
  it "can list cells that can be moved" do
    @puzzle.load([1, 5, 3, 4, 2, 6, 7, 8, nil])
    @puzzle.moveable_cells.sort.should == [[2,3], [3,2]]
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, nil, 8])
    @puzzle.moveable_cells.sort.should == [[2,2], [3,1], [3,3]]
  end
  
  it "can return the values of the board in order" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, nil, 8])
    @puzzle.get_values_as_array.should == [1, 2, 3, 4, 5, 6, 7, nil, 8]
  end
    
  it "knows which number to work on next" do
    @puzzle.load([1, nil, 3, 4, 5, 6, 7, 8, 2])
    @puzzle.get_next_out_of_place_number.should equal(2)
    @puzzle.load([1, 2, 3, 6, 5, 4, 7, 8, 2])
    @puzzle.get_next_out_of_place_number.should equal(4)
  end
  
  it "returns nil for number to work on next if there is nothing left to do" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.get_next_out_of_place_number.should be_nil
  end
    
  it "knows if a given cell contains the target number" do
    @puzzle.load([1, 1, 1, 4, nil, nil, nil, nil, nil])
    @puzzle.contains_target?([1,1]).should be_true
    @puzzle.contains_target?([1,2]).should be_false
    @puzzle.contains_target?([2,3]).should be_false
    @puzzle.contains_target?([3,3]).should be_true
    @puzzle.contains_target?([2,1]).should be_true
  end
  
  it "knows how to find neighbors" do
    @puzzle.find_neighbor([1,1], :right).should == [1,2]
    @puzzle.find_neighbor([1,1], :up).should be_nil
  end
  
  it "returns nil if there is no adjacent cell in the given direction" do
    @puzzle.find_neighbor([1,1], :left).should be_nil
  end
  
  it "knows how to shift the empty space left" do
    @puzzle.load([1, 2, 3, 4, nil, 6, 7, 8, 5])
    @puzzle.shift(nil, :left)
    @puzzle.empty_cell.should == [2,1]
  end
  
  it "knows how to shift the empty space right" do
    @puzzle.load([1, 2, 3, 4, nil, 6, 7, 8, 5])
    @puzzle.shift(nil, :right)
    @puzzle.empty_cell.should == [2,3]
  end
  
  it "knows how to shift the empty space down" do
    @puzzle.load([1, 2, 3, 4, nil, 6, 7, 8, 5])
    @puzzle.shift(nil, :down)
    @puzzle.empty_cell.should == [3,2]
  end
  
  it "knows how to shift the empty space up" do
    @puzzle.load([1, 2, 3, 4, nil, 6, 7, 8, 5])
    @puzzle.shift(nil, :up)
    @puzzle.empty_cell.should == [1,2]
  end
  
  it "knows whether or not it can shift the empty space in a given direction" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.can_shift?(nil, :up).should be_true
    @puzzle.can_shift?(nil, :right).should be_false
    @puzzle.can_shift?(nil, :down).should be_false
    @puzzle.can_shift?(nil, :left).should be_true
  end
  
  it "can find target cell for a given value" do
    @puzzle.find_target_cell(2).should == [1,2]
  end
  
  it "can find current cell for a given value" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, nil, 8])
    @puzzle.locate(2).should == [1,2]
  end
  
  it "can plot a path for the empty space to move to a given location" do
     @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
     @puzzle.plot_tile_shifts_to_move_empty_cell_to([3,2]).should == [:left]
     @puzzle.plot_tile_shifts_to_move_empty_cell_to([3,1]).should == [:left, :left]
     @puzzle.plot_tile_shifts_to_move_empty_cell_to([1,1]).should == [:up, :up, :left, :left]
  end
  
  it "can plot a path for the empty space around a simple obstacle" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.plot_tile_shifts_to_move_empty_cell_to([2,2], [[2,3]]).should == [:left, :up]
  end
  
  it "can plot a path for the empty space around a bigger obstacle" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.plot_tile_shifts_to_move_empty_cell_to([1,2], [[2,2],[2,3]]).should == [:left, :left, :up, :up, :right]
  end
  
  it "knows opposite directions" do
    @puzzle.opposite(:up).should equal(:down)
    @puzzle.opposite(:down).should equal(:up)
    @puzzle.opposite(:left).should equal(:right)
    @puzzle.opposite(:right).should equal(:left)
  end
  
  it "can take a compass reading between two points" do
    @puzzle.compass_reading_vertical([1,1], [3,3]).should == :down
    @puzzle.compass_reading_vertical([1,1], [1,3]).should == nil
    @puzzle.compass_reading_horizontal([1,3], [1,1]).should == :left
    @puzzle.compass_reading_vertical([3,3], [1,2]).should == :up
  end
  
  it "can plot a path around a vertical obstacle" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.plot_tile_shifts_to_move_empty_cell_to([1,1], [[1,2]]).should == [:up, :up, :down, :left, :left, :up]
  end
  
  it "can move empty to an arbitrary location" do
     @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
     @puzzle.move_empty_to([2,1])
     @puzzle.empty_cell.should == [2,1]
   end
  
  it "knows to leave the empty alone if asked to move it to the current empty location" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.move_empty_to([3,3])
    @puzzle.empty_cell.should == [3,3]
  end
   
   it "can move empty without disturbing a specified cell" do
     @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
     @puzzle.move_empty_to([2,1], [[2,3]])
     @puzzle.empty_cell.should == [2,1]
     @puzzle.board[[2,3]].should equal(6)
   end
   
  it "can shift a given tile left when there is a space to the left" do
    @puzzle.load([nil, 2, 3, 4, 5, 6, 7, 8, 1])
    @puzzle.shift(2, :left)
    @puzzle.locate(2).should == [1,1]
  end
    
  it "can shift a given tile left even if there is no blank space there" do
    @puzzle.load([1, 2, 3, 4, 5, 6, 7, 8, nil])
    @puzzle.shift(2, :left)
    @puzzle.locate(2).should == [1,1]
  end
  
  it "can move a tile to an arbitrary location" do
    @puzzle.load([3, 4, 7, 2, 5, 6, 1, 8, nil])
    @puzzle.move_tile_to(1, [1,1])
    @puzzle.locate(1).should == [1,1]
  end
  
  
  it "can move a tile to an arbitrary location without disturbing other tiles" do
    @puzzle.load([3, 4, 7, 2, 5, 6, 1, 8, nil])
    @puzzle.move_tile_to(1, [1,1], [[1,3]])
    @puzzle.locate(1).should == [1,1]
    @puzzle.locate(7).should == [1,3]
  end
  
  it "can rotate a circle of 4 tiles counter clockwise" do
    @puzzle.load([1,2,3,nil,4,5,6,7,8])
    @puzzle.rotate([[2,1],[3,2]], :counter_clockwise)
    @puzzle.locate(nil).should == [3,1]
    @puzzle.locate(4).should == [2,1]
    @puzzle.locate(7).should == [2,2]
    @puzzle.locate(6).should == [3,2]
  end
  
  it "can rotate a circle of 4 tiles clockwise" do
    @puzzle.load([1,2,3,nil,4,5,6,7,8])
    @puzzle.rotate([[1,1],[2,2]], :clockwise)
    @puzzle.locate(1).should == [1,2]
    @puzzle.locate(2).should == [2,2]
    @puzzle.locate(nil).should == [1,1]
    @puzzle.locate(4).should == [2,1]
  end
  
    
  it "can put the first row in order" do
    @puzzle.load([3, 4, 7, 2, 5, 6, 1, 8, nil])
    @puzzle.put_first_row_in_order
    @puzzle.locate(1).should == [1,1]
    @puzzle.locate(2).should == [1,2]
    @puzzle.locate(3).should == [1,3]
  end
  
  it "can put the second row in order" do
    @puzzle.load([1,2,3,8,4,5,6,nil,7])
    @puzzle.put_second_row_in_order
    @puzzle.locate(4).should == [2,1]
    @puzzle.locate(5).should == [2,2]
    @puzzle.locate(6).should == [2,3]
  end
  
  it "can solve certain permutations of the board" do
    @puzzle.load([1,2,3,8,4,5,6,nil,7])
    @puzzle.solve
    @puzzle.solved?.should be_true
  end
  
  it "can plot moves for the empty cell from [1,2] to [2,3] without disturbing [3,3]" do
    @puzzle.load([5, nil, 6, 7, 4, 2, 3, 8, 1])
    @puzzle.plot_tile_shifts_to_move_empty_cell_to([2,3]).should == [:down, :right]
  end
  
  it "can put the 1 at [1,1] even in this odd case" do
    @puzzle.load([5, nil, 6, 7, 4, 2, 3, 8, 1])
    @puzzle.move_tile_to(1, [1,1])
    @puzzle.locate(1).should == [1,1]
  end

  
  def solved_puzzle
    return {
      [1,1] => 1,
      [1,2] => 2,
      [1,3] => 3,
      [2,1] => 4,
      [2,2] => 5,
      [2,3] => 6,
      [3,1] => 7,
      [3,2] => 8,
      [3,3] => nil
    }
  end
end
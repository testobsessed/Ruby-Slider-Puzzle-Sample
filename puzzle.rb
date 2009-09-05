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

require 'pp'

class Puzzle
  
  attr :board
  def initialize
    @board = {
      [1,1] => nil,
      [1,2] => nil,
      [1,3] => nil,
      [2,1] => nil,
      [2,2] => nil,
      [2,3] => nil,
      [3,1] => nil,
      [3,2] => nil,
      [3,3] => nil
    }
  end
  
  def load(numbers)
    instructions = "must call with an Array of 9 items."
    raise "Invalid type: #{instructions}" if (numbers.class != Array)
    raise "Invalid length: #{instructions}" if (numbers.length != 9)
    @board = {
      [1,1] => numbers[0],
      [1,2] => numbers[1],
      [1,3] => numbers[2],
      [2,1] => numbers[3],
      [2,2] => numbers[4],
      [2,3] => numbers[5],
      [3,1] => numbers[6],
      [3,2] => numbers[7],
      [3,3] => numbers[8]
    }
  end
  
  def same_column?(from, to)
    return (from[1] == to[1])
  end
  
  def same_row?(from, to)
    return (from[0] == to[0])
  end
  
  def adjacent?(from, to)
    if same_row?(from, to)
      return ((from[1] - to[1]).abs == 1)
    else
      return ((from[0] - to[0]).abs == 1)
    end
  end
  
  def move_is_valid?(from, to)
    if ((same_column?(from, to) || same_row?(from, to)) && (adjacent?(from, to)))
      return true 
    else
      return false
    end
  end
  
  def can_move?(from, to)
    return true if (is_empty?(to)  && move_is_valid?(from, to))
    return false
  end
  
  def is_empty?(cell)
    if @board[cell].nil?
      return true
    else
      return false
    end
  end
  
  def move(from, to)
    raise "Invalid move attempted. Cannot move from [#{from[0]}, #{from[1]}] to [#{to[0]}, #{to[1]}]." if !can_move?(from, to)
    from_value = @board[from]
    to_value = @board[to]
    @board[from] = to_value
    @board[to] = from_value
  end
  
  def attempt_move(from, to)
    if can_move?(from, to)
      move(from, to)
      return true
    else
      return false
    end
  end
  
  def empty_cell
    @board.keys.each{ |cell|
      return cell if is_empty?(cell)
    }
  end
  
  def moveable_cells
    moveable_list = Array.new
    @board.keys.each{ |cell|
      moveable_list.push(cell) if can_move?(cell, empty_cell)
    }
    return moveable_list
  end
  
  def get_next_out_of_place_number
    current_order = get_values_as_array
    desired_order = [1,2,3,4,5,6,7,8,nil]
    place = 0
    desired_order.each{ |item|
      return item if desired_order[place] != current_order[place]
      place += 1
    }
    return nil
  end
  
  def print_game_status
    puts "The empty space is currently at [#{empty_cell[0]}, #{empty_cell[1]}]."
    puts "The next number to move into place is #{get_next_out_of_place_number}."
    puts "The current board looks like: "
    pp get_values_as_array
  end
  
  def move_empty_to(cell, do_not_disturb_list = [])
    return if (cell == empty_cell)
    moves = plot_tile_shifts_to_move_empty_cell_to(cell, do_not_disturb_list)
    moves.each {|direction|
      shift(nil, direction)
    }
  end
  
  def compass_reading_vertical(current, target)
    row_diff = current[0] - target[0]
    case row_diff
    when -2,-1
      return :down
    when 1,2
      return :up
    end
    return nil
  end
   
  def compass_reading_horizontal(current, target)
    col_diff = current[1] - target[1]
    case col_diff
    when -2,-1
      return :right
    when 1,2
      return :left
    end
    return nil
  end
  
  def get_move_preferences(vertical, horizontal)
    directions = [:up, :down, :left, :right]
    preferences = Array.new
    if !vertical.nil?
      preferences.push(vertical)
      directions.delete(vertical)
    end
    if !horizontal.nil?
      preferences.push(horizontal)
      directions.delete(horizontal)
    end
    directions.each {|direction|
      preferences.push(direction)
    }
    return preferences
  end
    
  def plot_tile_shifts_to_move_empty_cell_to(target, do_not_disturb_list = [])
    moves = Array.new
    current = empty_cell
    done = false
    while (!done)
      vertical = compass_reading_vertical(current, target)
      horizontal = compass_reading_horizontal(current, target)
      move_preferences = get_move_preferences(vertical, horizontal)
      # put the opposite of the most recent direction at the end of the preferences list
      if (!opposite(moves.last).nil?)
        move_preferences.delete(opposite(moves.last))
        move_preferences.push(opposite(moves.last))
      end
      possible_directions = list_available_directions(current, do_not_disturb_list)
      direction = pick_direction_given_options_and_preferences(possible_directions, move_preferences)
      if direction.nil?
        raise "No viable directions to move"
      end
      if (!find_neighbor(current, direction).nil?)
        moves.push(direction)
        current = find_neighbor(current, direction)
      else
        raise "Impossible to plot path from [#{empty_cell[0]}, #{empty_cell[1]}] to [#{target[0]}, #{target[1]}] given constraints #{do_not_disturb_list}."
      end
      done = (current == target)
    end
    return moves
  end
    
  def pick_direction_given_options_and_preferences(options, preferences)
    preferences.each { |direction| 
      if options.include?(direction)
        return direction
      end
    }
    return nil
  end
  
  def opposite(direction)
    case direction
    when :up
      return :down
    when :down
      return :up
    when :left
      return :right
    when :right
      return :left
    end
    return nil
  end
  
  def list_available_directions(from, forbidden = [])
    list = []
    up = find_neighbor(from, :up)
    down = find_neighbor(from, :down)
    left = find_neighbor(from, :left)
    right = find_neighbor(from, :right)
    list.push(:up) if (!up.nil? && !forbidden.include?(up))
    list.push(:down) if (!down.nil? && !forbidden.include?(down))
    list.push(:left) if (!left.nil? && !forbidden.include?(left))
    list.push(:right) if (!right.nil? && !forbidden.include?(right))
    return list
  end
  
  def find_neighbor(current, direction)
    row_offset = 0
    col_offset = 0
    case direction
    when :up
      row_offset = -1
    when :down
      row_offset = 1
    when :left
      col_offset = -1
    when :right
      col_offset = 1
    end
    new_row = current[0] + row_offset
    new_col = current[1] + col_offset
    if ((new_row <=3) && (new_row >= 1) && (new_col <=3) && (new_col >= 1))
      return [new_row , new_col]
    else
      return nil
    end
  end

  def shift(number, direction, do_not_disturb_list = [])
    current = locate(number)
    adjacent_cell = find_neighbor(current, direction)
    if (current != empty_cell)
      move_empty_to(adjacent_cell, [current] + do_not_disturb_list)
      move(current, empty_cell)
    else
      move(adjacent_cell, current)
    end
  end
  
  def can_shift?(number, direction)
    can_shift = false
    target = find_neighbor(locate(number), direction)
    return false if target.nil?
    if (!number.nil?)
      can_shift = can_move?(locate(number), target)
    else
      can_shift = can_move?(target, empty_cell)
    end
    return can_shift
  end
    
  def contains_target?(cell)
    return (find_target_cell(@board[cell]) == cell)
  end
  
  def find_target_cell(number)
    target_cell = nil
    @board.keys.sort.each{ |cell|
      return cell if solved_board[cell] == number 
    }    
  end
  
  def locate(number)
    @board.keys.sort.each{ |cell|
      return cell if @board[cell] == number
    }
  end
  
  def get_values_as_array
    values = Array.new
    @board.keys.sort.each{ |cell|
      values.push(@board[cell])
    }
    return values
  end
  
  def move_tile_to(number, target, do_not_disturb_list = [])
    return if (locate(number) == target)
    while (locate(number) != target)
      current = locate(number)
      possible_locations_for_blank = list_available_directions(current, do_not_disturb_list)
      vertical = compass_reading_vertical(current, target)
      horizontal = compass_reading_horizontal(current, target)
      if (possible_locations_for_blank.include?(vertical))
        direction = vertical
      elsif (possible_locations_for_blank.include?(horizontal))
        direction = horizontal
      elsif (possible_locations_for_blank.length != 0)
        direction = possible_locations_for_blank[0]
      else
        raise "Can't find a place to put the empty space"
      end
      not_moving = [current] + do_not_disturb_list
      move_empty_to(find_neighbor(locate(number), direction), not_moving)
      shift(number, direction)
    end
  end
  
  def rotate(range, direction)
    range = range.sort
    rows = [range[0][0], range[1][0]]
    cols = [range[0][1], range[1][1]]
    cells = [
      [rows[0], cols[0]],
      [rows[1], cols[0]],
      [rows[1], cols[1]],
      [rows[0], cols[1]]
    ]

    if (direction == :counter_clockwise)
      cells.reverse!
    end
    empty_index = cells.index(empty_cell)
    (0..(empty_index)).each {|n| cells.push(cells.shift)}
    cells.delete(empty_cell)
    cells.each { |cell|
      move(cell, empty_cell)
    }
  end
  
  def put_first_row_in_order
    move_tile_to(1, [1,1])
    move_tile_to(2, [1,2], [[1,1]])
    move_empty_to([2,1], [[1,1],[1,2]])
    rotate([[1,1],[2,2]], :counter_clockwise)
    move_tile_to(3, [1,3], [[1,1],[2,1]])
    move_empty_to([2,2], [[1,1],[2,1],[1,3]])
    rotate([[1,1],[2,2]], :clockwise)
  end
  
  def put_second_row_in_order
    do_not_disturb = [[1,1], [1,2], [1,3]]
    move_tile_to(4, [2,1], do_not_disturb)
    move_empty_to([3,2], do_not_disturb + [[2,1]])
    if (locate(5) != [2,2])
      if (locate(5) == [2,3])
        rotate([[2,2], [3,3]], :counter_clockwise)
      elsif (locate(5) == [3,3])
        rotate([[2,2], [3,3]], :counter_clockwise)
        rotate([[2,2], [3,3]], :counter_clockwise)
      else
        raise "Cannot solve this configuration."
      end
    end
    move_empty_to([3,2], do_not_disturb + [[2,1], [2,2]])
    rotate([[2,1], [3,2]], :counter_clockwise)
    move_empty_to([3,2], do_not_disturb + [[2,1], [3,1]])
    if (locate(6) != [2,2])
      if (locate(6) == [2,3])
        rotate([[2,2], [3,3]], :counter_clockwise)
      elsif (locate(6) == [3,3])
        rotate([[2,2], [3,3]], :counter_clockwise)
        rotate([[2,2], [3,3]], :counter_clockwise)
      else
        puts "FAIL: Board is..."
        pp board
        raise "Cannot solve this configuration."
      end
    end
    move_empty_to([2,3], do_not_disturb + [[2,1], [2,2], [3,1]])
    move(locate(6), empty_cell)
    move(locate(5), empty_cell)
    move(locate(4), empty_cell)
  end
  
  def solve
    put_first_row_in_order
    put_second_row_in_order
    move_empty_to([3,3], [[2,1], [2,2], [2,3]])
  end
  
  def solved?
    return @board == solved_board
  end
  
  def solved_board
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
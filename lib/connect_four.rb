class Board
  def initialize(width, height, grid = grid_setup(width, height))
    @grid = grid
    @width = width
    @height = height
  end

  def grid_setup(width, height)
    Array.new(height) { Array.new(width) { Cell.new } }
  end

  def find_lowest_empty(col, row = 0)
    cell = @grid[row][col]
    bottom = @height - 1

    return(row - 1) unless cell.value == "empty"
    return row if row == bottom

    find_lowest_empty(col, row + 1)
  end

  def add_piece(col, color) 
      row = find_lowest_empty(col)
      return row if row == -1
      @grid[row][col].set_value(color)
      [row, col]
  end

  def display_board
    grid_spaces = { "empty" => "[ ]", "red" => "[X]", "yellow" => "[O]" }

    puts
    @grid.each do |inner|
      puts inner.map { |cell| grid_spaces[cell.value] }.join("")
    end
    puts
  end

  def full?
    counts = @grid.map { |row| row.count { |cell| cell.value == "empty" } }
    total = 0
    counts.each { |elm| total += elm }

    return true if total == 0

    false
  end

  def winner?(last_move)
    row = last_move.first
    col = last_move.last
    value = @grid[row][col].value

    return true if vert(row, col, value)
    return true if horz(row, col, value)
    return true if desc(row, col, value)
    return true if asce(row, col, value)

    false
  end

  def vert(row, col, value)
    total = count_matches(row, col, "up", value)
    total += count_matches(row, col, "down", value)

    return true if total > 2
  end

  def horz(row, col, value)
    total = count_matches(row, col, "left", value)
    total += count_matches(row, col, "right", value)

    return true if total > 2
  end

  def desc(row, col, value)
    total = count_matches(row, col, "top_left", value)
    total += count_matches(row, col, "bot_right", value)

    return true if total > 2
  end

  def asce(row, col, value)
    total = count_matches(row, col, "top_right", value)
    total += count_matches(row, col, "bot_left", value)

    return true if total > 2
  end

  def count_matches(row, col, dir, value)
    return -1 if @grid[row] == nil || @grid[row][col] == nil
    return -1 unless @grid[row][col].value == value

    case dir
    when "up"
      return 1 + count_matches(row -= 1, col, dir, value)
    when "down"
      return 1 + count_matches(row += 1, col, dir, value)
    when "left"
      return 1 + count_matches(row, col -= 1, dir, value)
    when "right"
      return 1 + count_matches(row, col += 1, dir, value)
    when "top_left"
      return 1 + count_matches(row -= 1, col -= 1, dir, value)
    when "bot_right"
      return 1 + count_matches(row += 1, col += 1, dir, value)
    when "top_right"
      return 1 + count_matches(row -= 1, col += 1, dir, value)
    when "bot_left"
      return 1 + count_matches(row += 1, col -= 1, dir, value)
    else
      puts "ERROR INCORRECT DIRECTION"
    end
  end
end

class Game 
  def initialize(game_board = Board.new(7, 6))
    @game_board = game_board
    @current_player = "red"
    @waiting_player = "yellow"
  end

  def switch_current_player
    @current_player, @waiting_player = @waiting_player, @current_player
  end

  def game_status(last_move) 
    if @game_board.winner?(last_move)
      return 1
    elsif @game_board.full?
      return 0
    else
      return 2
    end
  end

  def valid_move_loop
    while true do
      puts "#{@current_player}'s turn. Please choose a column:"
      user_input = gets.to_i
      result = @game_board.add_piece(user_input, @current_player)
      break unless result == -1
      puts "That column is full"
    end

    result
  end

  def game_loop
    @game_board.display_board

    while true do
      last_move = valid_move_loop
      @game_board.display_board
      case game_status(last_move)
      when 0
        puts "Tie game."
        break
      when 1
        puts "#{@current_player} wins!"
        break
      when 2
      end
      switch_current_player
    end
  end
end

class Cell
  attr_reader :value

  def initialize(value = "empty")
    @value = value
  end

  def set_value(new_value)
    @value = new_value
  end
end

gaming = Game.new
gaming.game_loop

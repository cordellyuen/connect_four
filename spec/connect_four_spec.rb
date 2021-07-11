require_relative "../lib/connect_four"

describe Board do
  width = 7
  height = 6
  subject(:board) { described_class.new(width, height) }

  matcher :be_array do
    match do |possible_array|
      possible_array.kind_of?(Array)
    end
  end

  matcher :be_2d_array do
    match do |possible_2d|
      return false if possible_2d.empty?
      possible_2d.all? do |elm|
        elm.kind_of?(Array)
      end
    end
  end

  matcher :be_all_cell_obj do
    match do |grid|
      grid.all? do |inner|
        inner.all? do |elm|
          elm.kind_of?(Cell)
        end
      end
    end
  end
  
  describe "#initialize" do
    it "sets @grid to an array" do
      grid = board.instance_variable_get(:@grid)
      expect(grid).to be_array
    end

    it "sets @grid to a 2D array" do
      grid = board.instance_variable_get(:@grid)
      expect(grid).to be_2d_array
    end

    it "sets @grid with the correct width" do
      grid = board.instance_variable_get(:@grid)
      board_width = 7
      expect(grid[0].length).to eq(board_width)
    end

    it "sets @grid with the correct height" do
      grid = board.instance_variable_get(:@grid)
      board_height = 6
      expect(grid.length).to eq(board_height)
    end

    it "creates Cell objects for all elements of @grid" do
      grid = board.instance_variable_get(:@grid)
      expect(grid).to be_all_cell_obj
    end
  end

  describe "#find_lowest_empty" do
    it "returns a number" do
      return_value = board.find_lowest_empty(0)
      expect(return_value.kind_of?(Numeric)).to be true
    end

    it "returns number less than height of board" do
      return_value = board.find_lowest_empty(0)
      height = board.instance_variable_get(:@height)
      expect(return_value).to be < height
    end

    context "when the column is empty" do
      it "returns 5" do
        return_value = board.find_lowest_empty(0)
        expect(return_value).to eq(5)
      end
    end
    
    context "when the bottom cell is full" do
      test_grid = [ [Cell.new], [Cell.new], [Cell.new], 
      [Cell.new], [Cell.new], [Cell.new("yellow")] ]

      subject(:board) { described_class.new(1, 6, test_grid)}

      it "returns 4" do
        return_value = board.find_lowest_empty(0)
        expect(return_value).to eq(4)
      end
    end

    context "when the bottom two cells are full" do
      test_grid = [ [Cell.new], [Cell.new], [Cell.new], 
                  [Cell.new], [Cell.new("red")], [Cell.new("red")] ]

      subject(:board) { described_class.new(1, 6, test_grid)}

      it "returns 3" do
        return_value = board.find_lowest_empty(0)
        expect(return_value).to eq(3)
      end
    end

    context "when all cells full except for top" do
      test_grid = [ [Cell.new], [Cell.new("red")], [Cell.new("red")], 
                  [Cell.new("red")], [Cell.new("red")], [Cell.new("red")] ]

      subject(:board) { described_class.new(1, 6, test_grid)}

      it "returns 0" do
        return_value = board.find_lowest_empty(0)
        expect(return_value).to eq(0)
      end
    end

    context "when all cells are full" do
      test_grid = Array.new(6) { Array.new(1) { Cell.new("red") } }

      subject(:board) { described_class.new(1, 6, test_grid)}

      it "returns -1" do
        return_value = board.find_lowest_empty(0)
        expect(return_value).to eq(-1)
      end
    end
  end

  describe "#add_piece" do
    context "when updating a Cell value" do
      let(:test_cell) { instance_double(Cell, value: "empty") }
      let(:test_grid) { [ [test_cell] ] }
      subject(:board) { described_class.new(1, 1, test_grid) }

      it "sends set_value to Cell" do
        col = 0
        new_value = "red"
        expect(test_cell).to receive(:set_value).with(new_value)
        board.add_piece(col, new_value)
      end
    end

    context "when adding to a full column" do
      subject(:board) { described_class.new(7, 6) }

      before do
        allow(board).to receive(:find_lowest_empty).and_return(-1)
      end

      it "returns -1" do
        col = 0
        color = "red"
        return_value = board.add_piece(col, color)
        expect(return_value).to eq(-1)
      end
    end

    context "when adding to a non-full column" do
      subject(:board) { described_class.new(7, 6) }

      before do
        allow(board).to receive(:find_lowest_empty).and_return(2)
      end

      it "returns the row and col" do
        col = 0
        color = "red"
        return_value = board.add_piece(col, color)
        expect(return_value).to eq([2, 0])
      end
    end
  end

  describe "#winner?" do
    context "when latest move creates four matching vertically" do
      test_grid = [ [Cell.new], [Cell.new], [Cell.new("red")], 
                  [Cell.new("red")], [Cell.new("red")], [Cell.new("red")] ]

      subject(:board) { described_class.new(1, 6, test_grid)}

      it "returns true" do
        return_value = board.winner?([2, 0])
        expect(return_value).to be true
      end
    end

    context "when latest move creates four matching horizontally" do
      test_grid = [ [Cell.new, Cell.new, Cell.new("red"), 
                  Cell.new("red"), Cell.new("red"), Cell.new("red")] ]

      subject(:board) { described_class.new(7, 1, test_grid)}

      it "returns true" do
        return_value = board.winner?([0, 2])
        expect(return_value).to be true
      end
    end

    context "when latest move creates four matching descending" do
      test_grid = [ [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new],
                    [Cell.new, Cell.new, Cell.new("red"), Cell.new, Cell.new, Cell.new, Cell.new], 
                    [Cell.new, Cell.new, Cell.new, Cell.new("red"), Cell.new, Cell.new, Cell.new],
                    [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new("red"), Cell.new, Cell.new],
                    [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new("red"), Cell.new],
                    [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new] ]

      subject(:board) { described_class.new(7, 6, test_grid)}

      it "returns true" do
        return_value = board.winner?([2, 3])
        expect(return_value).to be true
      end
    end

    context "when latest move creates four matching ascending" do
      test_grid = [ [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new],
                    [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new("red"), Cell.new, Cell.new], 
                    [Cell.new, Cell.new, Cell.new, Cell.new("red"), Cell.new, Cell.new, Cell.new],
                    [Cell.new, Cell.new, Cell.new("red"), Cell.new, Cell.new, Cell.new, Cell.new],
                    [Cell.new, Cell.new("red"), Cell.new, Cell.new, Cell.new, Cell.new, Cell.new],
                    [Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new, Cell.new] ]

      subject(:board) { described_class.new(7, 6, test_grid)}

      it "returns true" do
        return_value = board.winner?([4, 1])
        expect(return_value).to be true
      end
    end

    context "when there are less than four in a row" do
      test_grid = [ [Cell.new], [Cell.new], [Cell.new("red")], 
                  [Cell.new("red")], [Cell.new("red")], [Cell.new("yellow")] ]

      subject(:board) { described_class.new(1, 6, test_grid)}

      it "returns false" do
        return_value = board.winner?([2, 0])
        expect(return_value).to be false
      end
    end
  end

  describe "#full?" do
    context "when the board has no empty space" do
      test_grid = Array.new(6) { Array.new(7) { Cell.new("red") } }

      subject(:board) { described_class.new(7, 6, test_grid)}

      it "returns true" do
        return_value = board.full?
        expect(return_value).to be true
      end
    end

    context "when the board has empty space" do
      test_grid = Array.new(6) { Array.new(7) { Cell.new } }

      subject(:board) { described_class.new(7, 6, test_grid)}

      it "returns false" do
        return_value = board.full?
        expect(return_value).to be false
      end
    end
  end
end

describe Game do
  subject(:game) { described_class.new }

  describe "#switch_current_player" do
    it "sets @waitng_player to @current_player" do
      expect { game.switch_current_player }.to change { 
        game.instance_variable_get(:@waiting_player) }.from("yellow").to("red")
      game.switch_current_player
    end

    it "sets @current_player to @waiting_player" do
      expect { game.switch_current_player }.to change { 
        game.instance_variable_get(:@current_player) }.from("red").to("yellow")
      game.switch_current_player
    end
  end

  describe "#game_status" do
    let(:board) { instance_double(Board) }
    subject(:game) { described_class.new(board) }

    context "when winner? is true and full? is false" do
      before do
        allow(board).to receive(:winner?).and_return(true)
        allow(board).to receive(:full?).and_return(false)
      end

      it "returns 1" do
        last_move = [0, 0]
        return_value = game.game_status(last_move)
        expect(return_value).to eq(1)
      end
    end

    context "when winner? is false and full? is true" do
      before do
        allow(board).to receive(:winner?).and_return(false)
        allow(board).to receive(:full?).and_return(true)
      end

      it "returns 0" do
        last_move = [0, 0]
        return_value = game.game_status(last_move)
        expect(return_value).to eq(0)
      end
    end

    context "when winner? is true and full? is true" do
      before do
        allow(board).to receive(:winner?).and_return(true)
        allow(board).to receive(:full?).and_return(true)
      end

      it "returns 1" do
        last_move = [0, 0]
        return_value = game.game_status(last_move)
        expect(return_value).to eq(1)
      end
    end

    context "when winner? is false and full? is false" do
      before do
        allow(board).to receive(:winner?).and_return(false)
        allow(board).to receive(:full?).and_return(false)
      end

      it "returns 2" do
        last_move = [0, 0]
        return_value = game.game_status(last_move)
        expect(return_value).to eq(2)
      end
    end
  end

  # describe "#show_game_result" do
  #   context "when there is a winner" do
  #     let(:board) { instance_double(Board) }
  #     subject(:game) { described_class.new(board) }

  #     before do
  #       allow()
  #     end
  #   end
  # end

  describe "#valid_move_loop" do
    context "when the selected col is full and then the next col is empty" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(board).to receive(:add_piece).and_return(-1, [0, 0])
        allow(game).to receive(:puts)
      end

      it "loops twice then stops" do
        expect(game).to receive(:gets).twice
        game.valid_move_loop
      end

      it "returns [0, 0]" do
        return_value = game.valid_move_loop
        expect(return_value).to eq([0, 0])
      end
    end

    context "when the selected col is empty" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(board).to receive(:add_piece).and_return([5, 0])
        allow(game).to receive(:puts)
      end

      it "loops once then stops" do
        expect(game).to receive(:gets).once
        game.valid_move_loop
      end

      it "returns [5, 0]" do
        return_value = game.valid_move_loop
        expect(return_value).to eq([5, 0])
      end
    end

    context "when the selected col is full, then full, then empty" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(board).to receive(:add_piece).and_return(-1, -1, [3, 2])
        allow(game).to receive(:puts)
      end

      it "loops three times then stops" do
        expect(game).to receive(:gets).exactly(3).times
        game.valid_move_loop
      end

      it "returns [3, 2]" do
        return_value = game.valid_move_loop
        expect(return_value).to eq([3, 2])
      end
    end

    context "when validating a move" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:puts)
        allow(game).to receive(:gets).and_return(2)
      end

      it "sends add_piece to game_board" do
        player = "red"
        expect(board).to receive(:add_piece).with(2, player)
        game.valid_move_loop
      end
    end

    context "when validating a move is successful" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:puts)
        allow(game).to receive(:gets).and_return(2)
        allow(board).to receive(:add_piece).and_return([5, 2])
      end

      it "returns the position of the move" do
        return_value = game.valid_move_loop
        expect(return_value).to eq([5, 2])
      end
    end
  end

  describe "#game_loop" do
    context "when #game_status is 1" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:game_status).and_return(1)
        allow(board).to receive(:display_board)
        allow(game).to receive(:puts)
      end

      it "runs loop one time" do
        expect(game).to receive(:valid_move_loop).once
        game.game_loop
      end
    end

    context "when #game_status is 0" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:game_status).and_return(0)
        allow(board).to receive(:display_board)
        allow(game).to receive(:puts)
      end

      it "runs loop one time" do
        expect(game).to receive(:valid_move_loop).once
        game.game_loop
      end
    end

    context "when #game_status is 2 then 1 or 0" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:game_status).and_return(2, 1)
        allow(board).to receive(:display_board)
        allow(game).to receive(:puts)
      end

      it "runs loop two times" do
        expect(game).to receive(:valid_move_loop).twice
        game.game_loop
      end
    end

    context "when #game_status is 2, 2, then 1 or 0" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:game_status).and_return(2, 2, 1)
        allow(board).to receive(:display_board)
        allow(game).to receive(:puts)
      end

      it "runs loop three times" do
        expect(game).to receive(:valid_move_loop).exactly(3).times
        game.game_loop
      end
    end

    context "when looping" do
      let(:board) { instance_double(Board) }
      subject(:game) { described_class.new(board) }

      before do
        allow(game).to receive(:game_status).and_return(1)
        allow(game).to receive(:gets)
        allow(game).to receive(:valid_move_loop)
        allow(game).to receive(:switch_current_player)
        allow(game).to receive(:puts)
      end

      it "sends message to @game_board" do
        expect(board).to receive(:display_board).twice
        game.game_loop
      end
    end
  end
end

describe Cell do
  subject(:cell) { described_class.new }

  describe "#initialize" do
    it "is made with a default value of: empty" do
      cell_value = cell.instance_variable_get(:@value)
      expect(cell_value).to eq("empty")
    end
  end

  describe "#set_value" do
    it "changes from old value to new value" do
      new_value = "red"
      expect { cell.set_value(new_value) }.to change { cell.value }.from("empty").to("red")
    end
  end
end

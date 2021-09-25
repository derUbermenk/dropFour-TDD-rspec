# frozen_string_literal: true

require_relative '../lib/board'

describe Board do
  describe '#initialize' do
    subject(:board) { described_class.new }
    matcher :be_of_size_7 do
      match { |something| something.size == 7 }
    end

    it 'creates 6 rows' do
      cells_size = board.instance_variable_get(:@cells).size
      expect(cells_size).to eq(6) 
    end

    it 'creates rows with 7 nil positions' do
      cells = board.instance_variable_get(:@cells)
      expect(cells).to all(be_of_size_7. and include(nil).exactly(7).times)
    end
  end

  describe '#drop_piece' do
    let(:piece) { "\u2660" }

    context 'when placing on an empty column' do
      context 'when placing on column 2' do
        subject(:board) { described_class.new }
        let(:cells) { board.instance_variable_get(:@cells) }

        it 'places piece on column 2 of row 6' do
          expect { board.drop_piece(piece, 2) }.to change { cells[5][2] }.to(piece)
        end
      end
    end

    context 'when placing on column where a row is occupied' do
      context 'when placing on column 5 and row 2 is occupied' do
        subject(:board) { described_class.new }
        let(:cells) { board.instance_variable_get(:@cells) }

        before do
          semi_filled_board = Array.new(6) do |index|
            index >= 2 ? Array.new(7, piece) : Array.new(7, nil)
          end

          board.instance_variable_set(:@cells, semi_filled_board)
        end

        it 'places piece on column 5 of row 1' do
          expect { board.drop_piece(piece, 5) }.to change { cells[1][5] }.to(piece)
        end
      end
    end
  end

  describe '#winner' do 
    subject(:board) { described_class.new }
    let(:spade) { "\u2660" }
    let(:diamond) { "\u2666" }
    context 'when winning piece forms a horizontal line' do
      before do

        # create some board
        winned_board = Array.new(6) do |index|
          index >= 1 ? Array.new(7, diamond) : Array.new(7, nil)
        end

        # edit board for a winning condition
        winned_board[2][2] = spade
        winned_board[2][3] = spade
        winned_board[2][4] = spade
        winned_board[2][5] = spade

        # for some variety added some spades too
        winned_board[3][5] = spade
        winned_board[1][2] = spade


        board.instance_variable_set(:@cells, winned_board)
      end

      it 'returns winning piece' do
        winning_piece = board.winner
        expect(winning_piece).to eql(spade)
      end
    end

    context 'when winning piece forms a vertical line' do
      before do
        # let winning piece be spade
        # create a condition where spade forms a vertical line
        winned_board = Array.new(6) do |index|
          index >= 1 ? Array.new(7, diamond) : Array.new(7, nil)
        end

        # create the winning line
        winned_board[2][1] = spade
        winned_board[3][1] = spade
        winned_board[4][1] = spade
        winned_board[5][1] = spade

        # add some other spades for variety
        winned_board[2][2] = spade
        winned_board[3][1] = spade

        board.instance_variable_set(:@cells, winned_board)
      end
      it 'returns winning piece' do
        winning_piece = board.winner
        expect(winning_piece).to eql(spade)
      end
    end

    context 'when winning piece forms a diagonal line' do
      before do
        # let winnning piece be diamond
        # create a condition where spade forms a horizontal line
        winned_board = Array.new(6) do |index|
          index >= 1 ? Array.new(7, diamond) : Array.new(7, nil)
        end

        # create the diagonal line
        winned_board[0][3]
        winned_board[1][2]
        winned_board[2][1]
        winned_board[3][0]

        # add other spades for variety
        winned_board[0][1]
        winned_board[2][0]

        board.instance_variable_set(:@cells, winned_board)
      end

      it 'returns winning piece' do
        winning_piece = board.winner
        expect(winning_piece).to eql(spade)
      end
    end
  end

  describe '#horizontal_match' do
    subject(:board) { described_class.new }
    let(:piece) {"\u2660"}
    context 'when there is match' do
      before do
        matching_row = [nil, nil, piece, piece, piece, piece, nil]
        allow(board).to receive(:get_row_elements).and_return(matching_row)
      end
      it 'returns true' do
        match_check = board.horizontal_match
        expect(match_check).to be true 
      end
    end

    context 'when there is no match' do
      before do
        matching_row = [nil, nil, piece, nil, piece, piece, nil]
        allow(board).to receive(:get_row_elements).and_return(matching_row)
        allow(board).to receive(:create_pattern).and_return(piece+piece+piece+piece)
      end

      it 'returns false' do
        match_check = board.horizontal_match
        expect(match_check).to be false
      end
    end
  end

  # if horizontal match works then so does vertical match
  describe '#vertical_match' do
    context 'when there is no match' do
      it 'returns false' do
      end
    end

    context 'when there is match' do
      it 'returns true' do
      end
    end
  end

  # if horizontal match works then so does vertical match
  describe 'diagonal_match' do
    context 'when there is no match' do
      it 'returns false' do
      end
    end

    context 'when there is match' do
      it 'returns true' do
      end
    end
  end

  describe '#full?' do
    subject(:board) { described_class.new }
    let(:piece) { "\u2660" }

    context 'when board is full?' do
      before do
        filled_board = Array.new(6) {Array.new(7, piece)}


        board.instance_variable_set(:@cells, filled_board)
      end

      it 'returns true' do
        expect(board).to be_full
      end
    end

    context 'when board is semi full?' do

      before do
        semi_filled_board = Array.new(6) do |index|
          index >= 2 ? Array.new(7, piece) : Array.new(7, nil)
        end

        board.instance_variable_set(:@cells, semi_filled_board)
      end

      it 'returns false' do
        expect(board).to_not be_full
      end
    end

    context 'when board is empty' do
      it 'returns false' do
        expect(board).to_not be_full
      end
    end
  end

  context 'private methods' do
    subject(:board) { described_class.new }
    
    describe '#get_row_elements' do
      context 'when querying for row 5' do
        let(:row5){ [*1..7] } 
        before do
          cells = board.instance_variable_get(:@cells)
          cells[5] = row5

          board.instance_variable_set(:@cells, cells)
        end

        it 'returns an array containing the elements of row 6' do
          queried_row = board.send(:get_row_elements, 5)
          expect(queried_row).to eql(row5)
        end
      end
    end

    describe '#get_column_elements' do
      context 'when querying for column 6' do
        let(:column6) { [*1..6] }
        before do
          cells = board.instance_variable_get(:@cells)
          # create a new array with zip, each element in zip contains
          #  ... a cell row and column value pair, calling each changes 
          #  ... each 6th element of each row to some col_val from column6
          # B )
          cells.zip(column6).each { |row, col_val| row[6] = col_val }
          board.instance_variable_set(:@cells, cells)
        end

        it 'returns an array containing the elements in column 6' do
          queried_column = board.send(:get_column_elements, 6)
          expect(queried_column).to eql(column6)
        end
      end
    end

    describe '#get_diagonal_elements' do
      context 'when querying the diagonals for cell[2][3]' do
        let(:diagonal1) { [*1..6] }
        let(:diagonal2) { [*0..5] }

        before do
          # for ease diagonal values are equal to row positions
          cells = board.instance_variable_get(:@cells)

          cells.zip(diagonal1, diagonal2.reverse).each do |row, diagonal1_val, diagonal2_val|
            diagonal1_position = diagonal1_val
            diagonal2_position = diagonal2_val

            row[diagonal1_position] = diagonal1_val
            row[diagonal2_position] = diagonal2_val
          end

          cells.instance_variable_set(:@cells, cells)
        end

        it 'returns a size 2 array of arrays containing diagonal bisectors of cell[2][3]' do
          #queried_diagonal_1 = board.send(:get_diagonal_elements, 2, 3, 1)
          #queried_diagonal_2 = board.send(:get_diagonal_elements, 2, 3, -1)


          #queried_diagonals = [queried_diagonal_1, queried_diagonal_2]
          queried_diagonals = [1,-1].each_with_object([]) do |slope, diagonals|
            diagonals << board.send(:get_diagonal_elements, 2, 3, slope)
          end

          expect(queried_diagonals).to eql([diagonal1, diagonal2])
        end
      end

      context 'when querying the diagonals for cell[5][6]' do
        let(:diagonal1) { [*1..6] }
        before do
          cells = board.instance_variable_get(:@cells)

          cells.zip(diagonal1).each do |row, diagonal_val|
            diagonal_pos = diagonal_val

            row[diagonal_pos] = diagonal_val
          end
        end
        it 'returns a size 1 array of arrays containing diagonal bisector of cell[5][6]' do
          queried_diagonals = [1,-1].each_with_object([]) do |slope, diagonals|
            diagonals << board.send(:get_diagonal_elements, 5, 6, slope)
          end
          expect(queried_diagonals).to eql([diagonal1])
        end
      end
    end

    describe '#get_points' do
      it 'returns the points withing the bounds of lines x1 = 0, y1 = 0, x2 = 5, y2 = 6' do; end
      
      context 'when querying the points of a positive sloped line' do
        context 'when querying for the points in line passing through (1, 3)' do
          it 'returns [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]]' do
            expected_points = [*0..4].zip([*1..5])
            queried_points = board.send(:get_points, 2, 3, 1)
            expect(queried_points).to eql(expected_points)
          end
        end

        context 'when querying for the points in line passing through cell[0][2]' do
          it 'returns [[2, 0], [3, 1], [4, 2], [5, 3], [6, 4]]' do
            expected_points = [*2..6].zip [*0..4]
            queried_points = board.send(:get_points, 2, 0, 1)
            expect(queried_points).to eql(expected_points)
          end
        end
      end

      context 'when querying for the points in a negative sloped line' do
        context 'when querying for the points in line passing through (3, 5)' do
          it 'returns [3, 5], [4, 4], [5, 3], [6, 2]' do
            expected_points = [*3..6].zip [*2..5].reverse
            queried_points = board.send(:get_points, 3, 5, -1)
            expect(queried_points).to eql(expected_points)
          end
        end

        context 'when querying for the points in line passing through (1, 2)' do
          it 'returns [0, 3], [1, 2], [2, 1], [3, 0]' do
            expected_points = [*0..3].zip [*0..3].reverse
            queried_points = board.send(:get_points, 1, 2, -1)
            expect(queried_points).to eql(expected_points)
          end
        end
      end
    end
  end
end


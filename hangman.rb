class Hangman
  attr_accessor :puzzle, :solution

  def load(puzzle_filepath, solution_filepath)
    @puzzle = File.open(puzzle_filepath).read
    @solution = File.open(solution_filepath).read

    if @puzzle.length != @solution.length
        raise BadInputDataError, "Puzzle and solution do not have the same number of characters and are therefore invalid"
    end
  end

  def get_diff
     
  end

end

class BadInputDataError < StandardError; end

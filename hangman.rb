class Hangman
  attr_accessor :puzzle, :solution, :solution_diff

  def load(puzzle_filepath, solution_filepath)
    @puzzle = File.open(puzzle_filepath).read
    @solution = File.open(solution_filepath).read

    @solution_diff = _get_solution_diff
    if @puzzle.length != @solution.length
      raise BadInputDataError, "Puzzle and solution do not have the same number of characters and are therefore invalid"
    end
  end

  def _get_solution_diff
    diff = {}
    @puzzle.split("").each_with_index do |puzzle_letter, pos|
      solution_letter = @solution[pos]
      if puzzle_letter == "_" and solution_letter != "_" 
        diff[solution_letter] ||= []
        diff[solution_letter].push pos 
      end
    end
    diff 
  end

  def guess(symbol)
    raise InvalidGuessError if not valid_guess?(symbol)
    if @solution_diff.include?(symbol)
      @solution_diff[symbol].count
    else
      0
    end
  end

  def valid_guess?(symbol)
    return false if ["_", " "].include?(symbol)
    return false if symbol.length > 1 
    true
  end
end

class InvalidGuessError < StandardError; end
class BadInputDataError < StandardError; end

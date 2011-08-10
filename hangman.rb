class Hangman
  attr_accessor :puzzle, :solution, :solution_diff, 
                :puzzle_with_guesses, :guesses_remaining,
                :guessed

  def self.load_if_filename(puzzle_or_filename)
    puzzle_or_filename = File.open(puzzle_or_filename).read if File.exists?(puzzle_or_filename)
    puzzle_or_filename
  end

  def self.load(puzzle, solution, guesses = 10)
    puzzle   = load_if_filename(puzzle)
    solution = load_if_filename(solution)
    self.new(puzzle, solution, guesses)
  end

  def initialize(puzzle_string, solution_string, number_of_guesses=10)
    @puzzle = puzzle_string
    @puzzle_with_guesses = String.new(@puzzle)
    @solution = solution_string

    if @puzzle.length != @solution.length
      raise BadInputDataError, "Puzzle and solution do not have the same 
                                number of characters and are therefore invalid"
    end

    @guessed = { :correct => [], :incorrect => [] }
    @guesses_remaining = number_of_guesses
    @solution_diff = get_solution_diff
  end

  def get_solution_diff
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

  def fill_puzzle_in_with(symbol)
    @solution_diff[symbol].each do |index|
      @puzzle_with_guesses[index] = symbol
    end
  end

  def guess(symbol)
    raise InvalidGuessError, "Invalid guess character" if not valid_guess?(symbol)
    raise InvalidGuessError, "You can not guess the same thing twice" if @guessed.values.flatten.include?(symbol)
    raise InvalidGuessError, "No guesses remaining" if @guesses_remaining <= 0

    if @solution_diff.include?(symbol)
      @guessed[:correct].push symbol 
      fill_puzzle_in_with symbol
    else
      @guessed[:incorrect].push symbol
      @guesses_remaining -= 1
      throw :game_over if @guesses_remaining == 0
    end

    number_of_occurences_in_solution(symbol)
  end

  def number_of_occurences_in_solution(symbol)
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

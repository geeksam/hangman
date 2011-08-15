require_relative 'hangman_parser.rb'

class Hangman
  attr_accessor :puzzle, :solution, :solution_diff, 
                :puzzle_with_guesses, :guesses_remaining,
                :guessed

  def self.load_if_filename(puzzle_or_filename)
    puzzle_or_filename = File.open(puzzle_or_filename).read if File.exists?(puzzle_or_filename)
    puzzle_or_filename
  end

  def self.new_game(puzzle, guesses = 10) 
    puzzle = load_if_filename(puzzle)
    self.new(puzzle, guesses)
  end

  #Changed a variable name from number_of_guesses to guesses to match self.load, to avoid confusion about why the same variable might be named differently
  def initialize(puzzle_data, guesses=10)
    parser = HangmanParser.new(puzzle_data); parser.parse
    @puzzle        = parser.puzzle
    @solution      = parser.solution
    @solution_diff = parser.solution_diff 
    
    @puzzle_with_guesses = String.new(@puzzle)
    @guessed             = { :correct => [], :incorrect => [] }
    @guesses_remaining   = guesses
  end

  def guess(symbol)
    #Handle multi-symbol guesses recursively in reverse order, so the deepest point of the stack is the first symbol
    if symbol.length > 1
      remaining_symbols = symbol[0..symbol.length-2]
      symbol            = symbol[symbol.length-1]  
      guess(remaining_symbols)
    end

    ensure_valid_guess!(symbol)

    if solution_contains?(symbol) and not already_guessed?(symbol) 
      @guessed[:correct].push symbol 
      fill_in_puzzle_with symbol
    else
      @guessed[:incorrect].push symbol
      @guesses_remaining -= 1
      throw :game_over if @guesses_remaining == 0
    end

    number_of_occurences_in_solution(symbol)
  end

  def solution_contains?(symbol)
    @solution_diff.include?(symbol)
  end

  def already_guessed?(symbol)
    @guessed.values.flatten.include?(symbol)
  end

  #Currently there are no invalid guesses
  def valid_symbol?(symbol)
    return false if [].include?(symbol)
    true
  end

  def ensure_valid_guess!(symbol)
    raise InvalidGuessError, "Invalid guess character" if not valid_symbol?(symbol)
    raise InvalidGuessError, "No guesses remaining" if @guesses_remaining <= 0
  end

  def number_of_occurences_in_solution(symbol)
    if @solution_diff.include?(symbol)
      @solution_diff[symbol].count
    else
      0
    end
  end

  def fill_in_puzzle_with(symbol)
    @solution_diff[symbol].each do |index|
      @puzzle_with_guesses[index] = symbol
    end
  end

end

class InvalidGuessError < StandardError; end
class BadInputDataError < StandardError; end

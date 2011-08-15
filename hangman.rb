class HangmanParser
  attr_accessor :puzzle, :solution, :solution_diff

  def initialize(puzzle_data)
    @puzzle_data = puzzle_data
  end 

  def parse
    @puzzle, @solution = get_puzzle_and_solution 
    @solution_diff     = get_solution_diff
  end

  def get_puzzle_and_solution
    puzzle, solution = "", ""
    #split on \n without consume by using ?= lookahead 
    puzzle_data_by_line = @puzzle_data.split(/(?=\n)/)
  
    puzzle_data_by_line.each_with_index do |line, num|
      unless hangman_instruction?(line)
        next_line = puzzle_data_by_line[num+1] || :EOF

        solution += line
        puzzle   += hangman_instruction?(next_line) ? hide_solution(line, next_line) : line
      end
    end

    return puzzle, solution
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

  def hangman_instruction?(line)
    comment_line_regexp = /^\s*[#][\^\s]*HANGMAN$/
    !!(line.match(comment_line_regexp))
  end

  #Hides the solution pieces of any line of text
  def hide_solution(solution, instruction)
    obscured_solution = String.new(solution)
    instruction.split("").each_with_index do |letter, pos|
      if letter == "^"
        obscured_solution[pos] = "_"
      end 
    end

    obscured_solution
  end
end

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

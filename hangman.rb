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
    @puzzle, @solution   = load_puzzle puzzle_data
    @solution_diff       = get_solution_diff
    @puzzle_with_guesses = String.new(@puzzle)

    @guessed             = { :correct => [], :incorrect => [] }
    @guesses_remaining   = guesses
  end

  def hangman_instruction?(line)
    comment_line_regexp = /^\s*[#][\^\s]*HANGMAN$/
    !!(line.match(comment_line_regexp))
  end

  def hide_solution(solution, instruction)
    obscured_solution = String.new(solution)
    instruction.split("").each_with_index do |letter, pos|
      if letter == "^"
        obscured_solution[pos] = "_"
      end 
    end

    obscured_solution
  end

  def load_puzzle(puzzle_data)
    puzzle, solution, previous_line = "", "", ""
   
    #split on \n without consume by using ?= lookahead 
    puzzle_data_by_line = puzzle_data.split(/(?=\n)/)
  
    puzzle_data_by_line.each_with_index do |line, num|
      next if hangman_instruction?(line) 
      next_line = puzzle_data_by_line[num+1] || :EOF

      solution += line
      puzzle   += hangman_instruction?(next_line) ? hide_solution(line, next_line) : line
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

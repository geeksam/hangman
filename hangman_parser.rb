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


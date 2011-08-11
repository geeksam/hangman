require 'rubygems'
require 'rspec'
require './hangman.rb'

describe Hangman do
  ValidPuzzle   = File.open("spec/sample_puzzle.txt").read
  ValidSolution = File.open("spec/sample_solution.txt").read

  describe "#load" do
    it "should reject puzzle and solution if they do not have the same number of characters" do
      valid_but_longer_solution = ValidSolution + "some other text"
      lambda { Hangman.load(ValidPuzzle, valid_but_longer_solution) }.should raise_error(BadInputDataError)
    end    

    it "should generate a hash that maps each character that is part of the solution to a position in the string" do
      @hangman = Hangman.load(ValidPuzzle, ValidSolution)
      # In this style of test, you've asserted the complete and correct solution.
      # Another style might be to spot-check a few values, assuming that if those were right, the rest probably was too.
      # (Both are fine in this case, but this is about the upper limit of test complexity I'm usually comfortable with.)
      # 
      # However, this test probably knows too much about the thing it's testing.
      # If you tweak your underlying implementation, this test will fail even if the class still behaves
      # exactly the same when sent a series of messages.
      # What value does this particular data structure -- on its own -- provide to a consumer of the class?
      correct_solution_diff = { 
        "i"=>[60], 
        "f"=>[61, 81], 
        "a"=>[63, 82], 
        "="=>[64,65],
        "b"=>[66], 
        "r"=>[74, 78], 
        "e"=>[75, 85, 91],
        "t"=>[76], 
        "u"=>[77],
        "n"=>[79, 92], 
        "l"=>[83], 
        "s"=>[84], 
        "d"=>[93] 
      }     
          
      @hangman.solution_diff.should == correct_solution_diff
    end
  end

  describe "#guess" do
    before(:each) do
      @hangman = Hangman.load(ValidPuzzle, ValidSolution)
    end

    it "should not allow guessing if there are no guesses remaining" do
      @hangman.guesses_remaining = 1
      symbol_not_in_solution = "z"
      # I don't often see throw/catch used in Ruby.  Still working through Exceptional Ruby myself, though, so maybe I'll find more reasons to use them.
      expect { @hangman.guess(symbol_not_in_solution) }.to throw_symbol(:game_over)
    end

    it "should return the number of occurrences when the symbol is in the puzzle" do
      @hangman.guess("a").should == 2
      @hangman.guess("r").should == 2
      @hangman.guess("i").should == 1
    end

    it "should return 0 when the symbol is valid but is not in the puzzle" do
      @hangman.guess("z").should == 0
    end 

    it "should raise an InvalidGuessError if it is not an acceptable guess string" do
      # Underscores have been known to appear in the answer key as well.  Not sure this behavior makes sense.
      # Possibly a guess of "abc" should be treated as .guess('a'); .guess('b'); .guess('c') ?
      invalid_characters = %w(aa _) 
      invalid_characters.each do |invalid_character|
        lambda { @hangman.guess(invalid_character) }.should raise_error(InvalidGuessError) 
      end
    end

    it "should have one less guess remaining if the guess is incorrect" do
      #expect { @hangman.guess("z") }.to change(@hangman.guesses_remaining, :abs).by(-1)
      expect { @hangman.guess("z") }.to change{@hangman.guesses_remaining}.by(-1)
    end 

    it "should not affect the number of guesses if the guess is correct" do
      expect { @hangman.guess("a") }.not_to change{@hangman.guesses_remaining}
    end

    it "should raise an InvalidGuessError if it has already been guessed" do
      # Or, consider this a no-op
      lambda { 2.times do; @hangman.guess("a"); end }.should raise_error(InvalidGuessError)
    end 

    it "should add (in)correctly guessed symbols to guessed[:(in)correct]" do
      guesses = %w[a b z x]
      guesses.each { |s| @hangman.guess(s) }
#                     ^ I almost always just use 'e' (short for 'element') here,
#                       unless the iterating block is more than a line or two long.
#                       It saves me having to think of a name for something that doesn't matter,
#                       and saves the reader from having to pay attention to it (as long as they know the convention).
#                       Fun fact:  did you know that '_' is a valid Ruby variable name?  (It has special behavior in IRB, though.)
#                       That comes in handy when you're iterating across, say, a table, and don't care about every column.

      @hangman.guessed[:correct].should == %w[a b]
      @hangman.guessed[:incorrect].should == %[z x]
    end
  end

  # I don't typically test 'helper' methods, as these are (a) often marked protected or private,
  # and (b) created via refactoring.  Because they're internal to the class, I tend to consider them
  # fair game for drastic refactoring, which tends to break tests that expected them to be there.
  # Much like the above test on #solution_diff, this should probably not be carried forward.
  # (The behavior is subject to change, and the test doesn't tell us much about it.)
  describe "#fill_puzzle_in_with" do
    before(:each) do
      @hangman = Hangman.load(ValidPuzzle, ValidSolution)
    end

    # Another style point:  when a test description says "#foo should be called when bar", I expect to see a mock or stub.
    it "should be called by guess to automatically fill in puzzle_with_guesses with the appropriate symbols" do
      @hangman.puzzle_with_guesses[63].should == "_"
      @hangman.puzzle_with_guesses[82].should == "_"
      @hangman.guess("a")
      @hangman.puzzle_with_guesses[63].should == "a"
      @hangman.puzzle_with_guesses[82].should == "a"
    end
  end
end


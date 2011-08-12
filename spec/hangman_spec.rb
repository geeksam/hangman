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

    #Marked for deletion! Leaving it for now ..
    it "should generate a hash that maps each character that is part of the solution to a position in the string" do
      @hangman = Hangman.load(ValidPuzzle, ValidSolution)
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
      # Brent: I might be wrong in doing it but my justification is that I believe catch and throw should be used to break from a loop / control flow, and in this instance we are trying to break from the 'game loop' so it seems like it's a good use case. What do you usually see used instead of catch/throw in these situations?
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
      # Sam: Underscores have been known to appear in the answer key as well.  Not sure this behavior makes sense.
      # Possibly a guess of "abc" should be treated as .guess('a'); .guess('b'); .guess('c') ?
      # Brent: Good point, I will look at incorporating this. If this is the case, I can't think of any invalid guesses! I'll leave this here nonetheless
      invalid_characters = %w() 
      invalid_characters.each do |invalid_character|
        lambda { @hangman.guess(invalid_character) }.should raise_error(InvalidGuessError) 
      end
    end

    it "should have one less guess remaining if the guess is incorrect" do
      #Brent: What's the reasoning behind including abs? Doesn't seem to work when I do it - Rspec says it was not changed
      expect { @hangman.guess("z") }.to change{@hangman.guesses_remaining}.by(-1)
    end 

    it "should not affect the number of guesses if the guess is correct" do
      expect { @hangman.guess("a") }.not_to change{@hangman.guesses_remaining}
    end

    it "should raise an InvalidGuessError if it has already been guessed" do
      # Sam: Or, consider this a no-op
      # Brent: What is a no-op?
      lambda { 2.times do; @hangman.guess("a"); end }.should raise_error(InvalidGuessError)
    end 

    it "should add (in)correctly guessed symbols to guessed[:(in)correct]" do
      guesses = %w[a b z x]
      guesses.each { |e| @hangman.guess(e) }

      @hangman.guessed[:correct].should == %w(a b)
      @hangman.guessed[:incorrect].should == %w(z x)
    end
  end
end


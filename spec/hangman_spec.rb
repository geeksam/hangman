require 'rubygems'
require 'rspec'
require './hangman.rb'

describe Hangman do
  before(:all) do
    @valid_puzzle = File.open("spec/sample_puzzle.txt").read
    @valid_solution = File.open("spec/sample_solution.txt").read
  end

  before(:each) do
    @hangman = Hangman.new
  end

  describe "#load" do
    it "should reject puzzle and solution if they do not have the same number of characters" do
      valid_but_longer_solution = @valid_solution + "some other text"
      lambda { @hangman.load(@valid_puzzle, valid_but_longer_solution) }.should raise_error(BadInputDataError)
    end    

    it "should generate a hash that maps each character that is part of the solution to a position in the string" do
      @hangman.load(@valid_puzzle, @valid_solution)
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
      @hangman = Hangman.new
      @hangman.load(@valid_puzzle, @valid_solution)
    end

    it "should not allow guessing if there are no guesses remaining" do
      @hangman.guesses_remaining = 1
      symbol_not_in_solution = "z"
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
      lambda { 2.times do; @hangman.guess("a"); end }.should raise_error(InvalidGuessError)
    end 

    it "should add (in)correctly guessed symbols to guessed[:(in)correct]" do
      correct = %w(a b)
      incorrect = %w(z x)

      correct.each do |s| @hangman.guess(s); end;
      incorrect.each do |s| @hangman.guess(s); end;

      @hangman.guessed[:correct].should == ["a","b"]
      @hangman.guessed[:incorrect].should == ["z","x"]
    end
  end

  describe "#fill_puzzle_in_with" do
    before(:each) do
      @hangman.load(@valid_puzzle, @valid_solution)
    end

    it "should be called by guess to automatically fill in puzzle_with_guesses with the appropriate symbols" do
      @hangman.puzzle_with_guesses[63].should == "_"
      @hangman.puzzle_with_guesses[82].should == "_"
      @hangman.guess("a")
      @hangman.puzzle_with_guesses[63].should == "a"
      @hangman.puzzle_with_guesses[82].should == "a"
    end
  end
end


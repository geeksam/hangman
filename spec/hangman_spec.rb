require 'rubygems'
require 'rspec'
require './hangman.rb'

describe Hangman do
  describe "#load" do
    before(:each) do
      @hangman = Hangman.new
    end

    it "should reject puzzle and solution if they do not have the same number of characters" do
      lambda { @hangman.load("spec/sample_puzzle.txt", "spec/invalid_sample_solution.txt") }.should raise_error(BadInputDataError)
    end    

    it "should generate a hash that maps each character that is part of the solution to a position in the string" do
      @hangman.load("spec/sample_puzzle.txt", "spec/sample_solution.txt")
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
      @hangman.load("spec/sample_puzzle.txt", "spec/sample_solution.txt")
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
  end
end


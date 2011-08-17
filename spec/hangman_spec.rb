require 'rubygems'
require 'rspec'
require './hangman.rb'

describe Hangman do
  ValidPuzzle = File.open("spec/sample_puzzle.txt").read

  describe "#new_game" do
  end

  describe "#guess" do
    before(:each) do
      @hangman = Hangman.new_game(ValidPuzzle)
    end

    it "should throw game over if there are no guesses remaining" do
      @hangman.guesses_remaining = 1
      symbol_not_in_solution = "z"
      # I don't often see throw/catch used in Ruby.  Still working through Exceptional Ruby myself, though, so maybe I'll find more reasons to use them.
      # Brent: I might be wrong in doing it but my justification is that I believe catch and throw should be used to break from a loop / control flow, and in this instance we are trying to break from the 'game loop' so it seems like it's a good use case. What do you usually see used instead of catch/throw in these situations?
      # Sam: Exceptions, mostly (intentional and otherwise).
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

    it "should accept guesses with more than one symbol at a time and apply them in order from left to right" do
      @hangman.guess("abc")
      #How do I test this?
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
      # Sam: "No Operation" -- the machine instruction you used on ancient computers when
      # you needed to waste some time.  ;>  aka "NOP", for one assembly version of same.
      pending "This test may no longer be necessary - if someone wants to guess the same letter twice, that's their fault!"
      #lambda { 2.times do; @hangman.guess("a"); end }.should raise_error(InvalidGuessError)
    end 

    it "should add (in)correctly guessed symbols to guessed[:(in)correct]" do
      guesses = %w[a b z x]
      guesses.each { |e| @hangman.guess(e) }

      @hangman.guessed[:correct].should == %w(a b)
      @hangman.guessed[:incorrect].should == %w(z x)
    end
  end
end


require 'rubygems'
require 'rspec'
require './hangman.rb'

describe Hangman do
  describe "#load" do
    before(:each) do
      @hangman = Hangman.new
    end

    it "should reject puzzle and solution if they do not have the same number of characters" do
      lambda { @hangman.load("spec/sample_puzzle.txt", "spec/invalid_sample_solution.txt")}.should raise_error(BadInputDataError)
    end    

    it "should return nothing upon successfully loading valid puzzle and solution files" do
      @hangman.load("spec/sample_puzzle.txt", "spec/sample_solution.txt").should do_nothing
    end

    it "should generate a hash that maps each character that is part of the solution to a position in the string" do
      fail
    end
  end
end


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'qp/parser'

describe "basic query parsing" do
  basic_terms = %w(a ab 123 a1 2b foo_bar baz-baz ACME)
  basic_terms.each do |term|
    it "should parse the single query term '#{term}'" do
      Parser.parse(term).should_not be nil
    end
  end

  it "should label a single term with T:<term>" do
    Parser.parse("something").should == ["T:something"]
  end

  it "should be ok with leading and trailing space" do
    Parser.parse(" leading").should == ["T:leading"]
    Parser.parse("trailing ").should == ["T:trailing"]
  end

  %w(AND OR).each do |t|
    it "should not allow #{t} as a term" do
      lambda { Parser.parse(t) }.should raise_error(ParseError)
    end
  end
end

describe "multiple terms" do
  it "should allow multiple terms" do
    Parser.parse("a b cdefg").should == ["T:a", "T:b", "T:cdefg"]
  end
end

describe "boolean queries" do
  describe "two term basic and/or" do
    binary_operators = [['AND', 'AND'], ['&&', 'AND'], ['OR', 'OR'], ['||', 'OR']]
    binary_operators.each do |op, op_name|
      expect = "(OP:#{op_name} T:t1 T:t2)"
      it "should parse 't1 #{op} t2' => #{expect}" do
        Parser.parse("t1 #{op} t2").should == [expect]
      end
    end
  end

  it "should allow a string of terms with ands and ors" do
    expect = "(OP:AND T:t1 (OP:OR T:t2 (OP:AND T:t3 T:t4)))"
    Parser.parse("t1 AND t2 OR t3 AND t4").should == [expect]
  end
end

describe "grouping with parens" do
  it "should create a single group for (aterm)" do
    Parser.parse("(aterm)").should == [["T:aterm"]]
  end

  describe "booleans and grouping" do

    it "should handle a simple grouped query" do
      Parser.parse("(a && b)").should == [["(OP:AND T:a T:b)"]]
      Parser.parse("(a AND b)").should == [["(OP:AND T:a T:b)"]]
      Parser.parse("(a || b)").should == [["(OP:OR T:a T:b)"]]
      Parser.parse("(a OR b)").should == [["(OP:OR T:a T:b)"]]
    end

    it "should handle a LHS group" do
      expect = ["(OP:OR (OP:AND T:a T:b) T:c)"]
      Parser.parse("(a && b) OR c").should == expect
      Parser.parse("(a && b) || c").should == expect
    end

    it "should handle a RHS group" do
      expect = ["(OP:OR T:c (OP:AND T:a T:b))"]   
      Parser.parse("c OR (a && b)").should == expect
      Parser.parse("c OR (a AND b)").should == expect
    end

        it "should handle both sides as groups" do
      expect = ["(OP:OR T:c (OP:AND T:a T:b))"]   
      Parser.parse("(c AND d) OR (a && b)").should == expect
    end

  end
end

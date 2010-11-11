require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'qp/parser'

describe "single term queries" do
  basic_terms = %w(a ab 123 a1 2b foo_bar baz-baz)
  basic_terms << "  leading"
  basic_terms << "trailing "
  basic_terms += %w(XAND ANDX XOR ORX XNOT NOTX)
  basic_terms.each do |term|
    expect = ["T:#{term.strip}"]
    it "'#{term}' => #{expect.inspect}" do
      Parser.parse(term).should == expect
    end
  end
  describe "invalid" do
    %w(AND OR NOT :).each do |t|
      it "'#{t}' => ParseError" do
        lambda { Parser.parse(t) }.should raise_error(ParseError)
      end
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

  describe "and booleans" do

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
      expect = ["(OP:OR (OP:AND T:c T:d) (OP:AND T:a T:b))"]   
      Parser.parse("(c AND d) OR (a && b)").should == expect
    end
  end
end

describe "NOT queries" do
  # input, output
  [
   ["a NOT b", ["T:a", "(OP:NOT T:b)"]],
   ["a NOT (b || c)", ["T:a", "(OP:NOT (OP:OR T:b T:c))"]]
  ].each do |input, expected|
    it "should parse '#{input}' => #{expected.inspect}" do
      Parser.parse(input).should == expected
    end
  end

  ["NOT", "a NOT", "(NOT)"].each do |d|
    it "should raise a ParseError on '#{d}'" do
      lambda { Parser.parse(d) }.should raise_error(ParseError)
    end
  end
end

describe 'required and prohibited prefixes (+/-)' do
  ["+", "-"].each do |kind|
    [
     ["#{kind}foo", ["(OP:#{kind} T:foo)"]],
     ["bar #{kind}foo", ["T:bar", "(OP:#{kind} T:foo)"]],
     ["(#{kind}oneA twoA) b", [["(OP:#{kind} T:oneA)", "T:twoA"], "T:b"]]
    ].each do |input, expect|
      it "should parse '#{input} => #{expect.inspect}" do
        Parser.parse(input).should == expect
      end
    end
  end

  it 'ignores + embedded in a term' do
    Parser.parse("one+two").should == ["T:one+two"]
  end
  
  it 'ignores - embedded in a term' do
    Parser.parse("one-two").should == ["T:one-two"]
  end
end

describe "strings" do
  phrases = [['"single"', ['STR:"single"']],
             ['"two term"', ['STR:"two term"']]
             ]
  phrases.each do |phrase, expect|
    it "'#{phrase}' => #{expect.inspect}" do
      Parser.parse(phrase).should == expect
    end
  end

  describe "invalid" do
    bad = ['""', '":not:a:term"', '"a :bad:']
    bad.each do |t|
      it "'#{t}' => ParseError" do
        lambda { Parser.parse(t) }.should raise_error(ParseError)
      end
    end
  end
  
end

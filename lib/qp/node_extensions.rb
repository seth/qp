require 'treetop'

module Lucene
  class Term < Treetop::Runtime::SyntaxNode
    def to_array
      "T:#{self.text_value}"
    end
  end

  class Body < Treetop::Runtime::SyntaxNode
    def to_array
      self.elements.map { |x| x.to_array }
    end
  end

  class Group < Treetop::Runtime::SyntaxNode
    def to_array
      self.elements[0].to_array
    end
  end

  class BooleanExpression < Treetop::Runtime::SyntaxNode
    def to_array
      op = self.elements[1].to_array
      a = self.elements[0].to_array
      b = self.elements[2].to_array
      "(#{op} #{a} #{b})"
    end
  end

  class AndOperator < Treetop::Runtime::SyntaxNode
    def to_array
      "OP:AND"
    end
  end

    class OrOperator < Treetop::Runtime::SyntaxNode
    def to_array
      "OP:OR"
    end
  end

end

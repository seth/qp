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

  class BinaryOp < Treetop::Runtime::SyntaxNode
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

  class UnaryOp < Treetop::Runtime::SyntaxNode
    def to_array
      op = self.elements[0].to_array
      a = self.elements[1].to_array
      "(#{op} #{a})"
    end
  end
  
  class NotOperator < Treetop::Runtime::SyntaxNode
    def to_array
      "OP:NOT"
    end
  end

  class RequiredExpression < Treetop::Runtime::SyntaxNode
    def to_array
      a = self.elements[0].to_array
      "(OP:+ #{a})"
    end
  end

  class RequiredOperator < Treetop::Runtime::SyntaxNode
    def to_array
      "OP:+"
    end
  end

  class ProhibitedOperator < Treetop::Runtime::SyntaxNode
    def to_array
      "OP:-"
    end
  end

end

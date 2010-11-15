require 'treetop'

module Lucene
  class Term < Treetop::Runtime::SyntaxNode
    def to_array
      "T:#{self.text_value}"
    end
  end

  class Field < Treetop::Runtime::SyntaxNode
    def to_array
      field = self.elements[0].text_value
      term = self.elements[1].to_array
      "(F:#{field} #{term})"
    end
  end

  # TODO: field ranges have some duplication to DRY up
  class InclFieldRange < Treetop::Runtime::SyntaxNode
    def to_array
      field = self.elements[0].text_value
      range_start = self.elements[1].to_array
      range_end = self.elements[2].to_array
      "(FR:#{field} [#{range_start}] [#{range_end}])"
    end
  end

  class ExclFieldRange < Treetop::Runtime::SyntaxNode
    def to_array
      field = self.elements[0].text_value
      range_start = self.elements[1].to_array
      range_end = self.elements[2].to_array
      "(FR:#{field} {#{range_start}} {#{range_end}})"
    end
  end

  class RangeValue < Treetop::Runtime::SyntaxNode
    def to_array
      self.text_value
    end
  end

  class FieldName < Treetop::Runtime::SyntaxNode
    def to_array
      self.text_value
    end
  end


  class Body < Treetop::Runtime::SyntaxNode
    def to_array
      "(" + self.elements.map { |x| x.to_array }.join(" ") + ")"
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

  class FuzzyOp < Treetop::Runtime::SyntaxNode
    def to_array
      a = self.elements[0].to_array
      param = self.elements[1]
      if param
        "(OP:~ #{a} #{param.to_array})"
      else
        "(OP:~ #{a})"
      end
    end
  end

  class BoostOp < Treetop::Runtime::SyntaxNode
    def to_array
      a = self.elements[0].to_array
      param = self.elements[1]
      "(OP:^ #{a} #{param.to_array})"
    end
  end

  class FuzzyParam < Treetop::Runtime::SyntaxNode
    def to_array
      self.text_value
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

  class Phrase < Treetop::Runtime::SyntaxNode
    def to_array
      "STR:#{self.text_value}"
    end
  end


end

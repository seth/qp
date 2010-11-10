module Lucene
  class Term < Treetop::Runtime::SyntaxNode
    def to_array
      "T:#{self.text_value}"
    end
  end

  # class Expression < Treetop::Runtime::SyntaxNode
  #   def to_array
  #     self.elements[0].to_array
  #   end
  # end

  class Body < Treetop::Runtime::SyntaxNode
    def to_array
      self.elements.map { |x| x.to_array }
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

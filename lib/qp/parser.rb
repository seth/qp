require 'treetop'
require 'qp/node_extensions'

class ParseError < StandardError
end

class Parser
  @@base_path = File.expand_path(File.dirname(__FILE__))
  Treetop.load(File.join(@@base_path, 'lucene.treetop'))
  @@parser = LuceneParser.new

  def self.parse(data)
    tree = @@parser.parse(data)
    raise ParseError, "Parse error at offset: #{@@parser.index}" if tree.nil?
    self.clean_tree(tree)
    tree.to_array
  end

  private

  def self.clean_tree(root_node)
    return if root_node.elements.nil?
    root_node.elements.delete_if do |node|
      node.class.name == "Treetop::Runtime::SyntaxNode"
    end
    root_node.elements.each { |node| self.clean_tree(node) }
  end
end


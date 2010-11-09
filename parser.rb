require 'treetop'

BASE_PATH = File.expand_path(File.dirname(__FILE__))

require File.join(BASE_PATH, 'node_extensions.rb')

class Parser
  Treetop.load(File.join(BASE_PATH, 'lucene.treetop'))
  @@parser = LuceneParser.new

  def self.parse(data)
    tree = @@parser.parse(data)
    raise Exception, "Parse error at offset: #{@@parser.index}" if tree.nil?
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

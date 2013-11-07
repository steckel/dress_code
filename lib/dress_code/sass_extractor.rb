require 'sass'
require_relative '../dress_code'
require_relative 'document'

class DressCode::SassExtractor

  attr_accessor :files

  def initialize(opts)
    @files = opts[:files]
    @base_dir = opts[:base_dir]
    @matcher = %r{@styleguide\s+([a-zA-Z\s]*)(\n.*)}m
  end

  def extract
    parse_files.sort_by { |doc| doc.component }
  end
  alias_method :docs, :extract

  def parse_files
    @files.flat_map { |path| parse_file(path) }.compact
  end

  def parse_file(path)
    src = File.read(path)
    ast = Sass::Engine.new(src,{}).to_tree

    @comments = []
    ast.children.each do |child|
      @comments.push(child) if child.is_a?(Sass::Tree::CommentNode)
    end

    matches = @comments.map { |comment|
      scan(comment.value[0])[0]
    }.compact
    return unless matches.length
    matches.map { |match| create_doc(match, path) }
  end

  def scan(src)
    src.scan(@matcher)
  end

  # must return an instance of Doc
  def create_doc(match, path)
    component = match[0]
    prose = match[1].gsub(%r{\/\/\s}, '').gsub(%r{\n},"\n\n").strip
    DressCode::Document.new({
      :component => component,
      :prose => prose,
      :path => path,
      :relative_path => path.gsub(@base_dir, '').gsub(/^\//, '')
    })
  end

end


require 'redcarpet'
require 'rouge'
require_relative '../dress_code'

class DressCode::Renderer < Redcarpet::Render::HTML

  def block_code(code, language)
    formatter = Rouge::Formatters::HTML.new(:css_class => 'highlight')
    lexer     = Rouge::Lexers::Shell.new
    syntax    = formatter.format(lexer.lex(code))

    inner = if language == 'html'
      "#{syntax} <div class='code-rendered'>#{code}</div>"
    else
      syntax
    end
    "<div class='code-demo'>#{inner}</div>"
  end

end


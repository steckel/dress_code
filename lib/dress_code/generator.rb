require 'sass'
# require 'sass/plugin'
# require 'compass'
require 'mustache'
require_relative '../dress_code'

class DressCode::Generator

  STATIC = "#{File.dirname(__FILE__)}/../static"
  TEMPLATE = "#{STATIC}/styleguide.html.mustache"

  def initialize(opts)
    @out_file = opts[:out_file] || 'styleguide.html'
    @docs = opts[:docs]
    @css = css opts
    @js = opts[:js]
    @template = opts[:template] || TEMPLATE
    @inline_css = opts[:dress_code_css].nil? ? true : !!opts[:dress_code_css]
    @inline_js = opts[:dress_code_js].nil? ? true : !!opts[:dress_code_js]
  end

  def css(opts)
    # Return unless there are css for us to fuck with
    return if opts[:css].nil?

    css_options = opts[:css]
    # Compile the sass to css if there is any
    if css_options.match 'sass'
      base_dir = opts[:base_dir] || '.'
      out_file = opts[:out_file]

      # find out where to compile sass to...
      last_dir_index = out_file.rindex '/'
      stylesheet_dir = out_file.slice 0..last_dir_index
      stylesheet_out = "#{stylesheet_dir}stylesheets/#{css_options.gsub('sass','css')}"

      # make directories that may not exist yet (and where we want to compile to)
      last_dir_index = stylesheet_out.rindex '/'
      FileUtils.mkdir_p stylesheet_out.slice 0...last_dir_index

      # compile the fucking thing
      # Sass.compile_file css_options, stylesheet_out

      # Compass.add_configuration({
      #     :project_path => '.',
      #     :sass_path => base_dir,
      #     :css_path => '.',
      #     :sass_options => {
      #       :load_paths => [
      #         '/Users/steckel/Development/dashboard/app/assets/stylesheets',
      #         '/Users/steckel/Development/dashboard/vendor/assets/stylesheets',
      #         '/Users/steckel/.gem/ruby/1.9.3/gems/compass-0.12.2/frameworks/blueprint/stylesheets',
      #         '/Users/steckel/.gem/ruby/1.9.3/gems/compass-0.12.2/frameworks/compass/stylesheets'
      #       ]
      #     }
      #   },
      #   'dress_code'
      # )
      # Compass.compiler.compile css_options, stylesheet_out

      # return the path to the compiled sass/css to include
      stylesheet_out.gsub %r{^#{stylesheet_dir}}, ''
    else
      # return the path to the css to include
      css_options
    end
  end

  def generate
    template = File.read(@template)
    write_file(@out_file, Mustache.render(template, {
      :docs => map_docs,
      :css => @css,
      :js => @js,
      :dress_code_css => dress_code_css,
      :dress_code_js => dress_code_js
    }))
  end

  def dress_code_css
    return unless @inline_css
    File.read("#{STATIC}/base.css") + File.read("#{STATIC}/github.css")
  end

  def dress_code_js
    return unless @inline_js
    File.read("#{STATIC}/docs.js")
  end

  def map_docs
    @docs.map { |doc| map_doc(doc) }
  end

  def map_doc(doc)
    {
      :id => "#{doc.component.gsub(' ', '_').downcase}",
      :prose => doc.to_html,
      :component => doc.component,
      :file => doc.relative_path
    }
  end

  def write_file(path, content)
    File.open(path, 'w') do |file|
      puts "# writing file: #{path}"
      file.write(content)
    end
  end

end


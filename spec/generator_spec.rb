require_relative 'spec_helper'

describe DressCode::Generator do

  before :each do
    doc = DressCode::Document.new({
      :component => 'button',
      :prose => "```html\n<button>I am a button</button>\n```",
      :path => '/whever/button.css',
      :relative_path => 'button.css'
    })
    @docs = [doc]
  end

  it "generates the styleguide html file" do
    generator = DressCode::Generator.new({
      :out_file => 'tmp/styleguide.html',
      :docs => @docs
    })
    generator.generate()
    File.exists?('tmp/styleguide.html').should == true
    # nokogiri this crap up
  end

  describe "css options" do
    context "with css" do
      it "includes css files" do
        path_to_css = 'path/to/some.css'

        generator = DressCode::Generator.new({
          :out_file => 'tmp/styleguide.html',
          :docs => @docs,
          :css => path_to_css
        })
        generator.generate()
        File.exists?('tmp/styleguide.html').should == true
        src = File.read('tmp/styleguide.html')
        src.scan(%r{<link.+href=(?:'|")#{path_to_css}(?:'|")}).length.should_not == 0
        # nokogiri this crap up
      end
    end

    context "with sass" do
      it "compiles sass into css and includes it" do
        path_to_sass = 'examples/stylesheets/complex_boxes.sass'
        out_file = 'tmp/styleguide.html'

        last_dir_index = out_file.rindex '/'
        stylesheet_out = "#{out_file.slice 0..last_dir_index}stylesheets/"
        path_to_compiled_sass = "#{stylesheet_out}#{path_to_sass.gsub('sass','css')}"
        # tmp/stylesheets/examples/stylesheets/boxes.sass

        generator = DressCode::Generator.new({
          :out_file => out_file,
          :docs => @docs,
          :css => path_to_sass,
        })
        generator.generate()

        File.exists?(out_file).should == true
        src = File.read out_file
        src.scan(%r{<link.+href=(?:'|")stylesheets/examples/stylesheets/complex_boxes\.css(?:'|")}).length.should_not == 0
        File.exists?(path_to_compiled_sass).should == true
        # nokogiri this crap up
      end
    end
  end

  it "includes js files"

end


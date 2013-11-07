require_relative 'spec_helper'

def create_test_file
  path = "tmp/test.css"
  directory = File.dirname(path)
  FileUtils.mkdir_p(directory) unless Dir.exists?(directory)
  test_file_content = "
//
  @styleguide button
  ```html
  <button>I am a button</button>
  ```
$blue: rgb(0,0,255)

button
  background: $blue

//
  @styleguide anchor
  ```html
  <a>I am an anchor</a>
  ```

a
  text-decoration: none

  &:hover
    text-decoration: underline
"
  File.open(path, 'w') do |file|
    file.write(test_file_content)
  end
  path
end


describe DressCode::SassExtractor do

  before :each do
    @test_file = create_test_file
    @extractor = DressCode::SassExtractor.new({
      :files => [@test_file],
      :base_dir => 'tmp'
    })
  end

  it "extracts documentation from files" do
    docs = @extractor.extract
    docs.length.should == 2
    docs[0].component.should == 'anchor'
    docs[0].prose.should == "```html\n\n<a>I am an anchor</a>\n\n```"
    docs[0].path.should == "tmp/test.css"
    docs[0].relative_path.should == "test.css"
    docs[1].component.should == 'button'
    docs[1].prose.should == "```html\n\n<button>I am a button</button>\n\n```"
    docs[1].path.should == "tmp/test.css"
    docs[1].relative_path.should == "test.css"
  end

end


require 'wml_action'

describe WmlAction::Section do

  it "should be created from file" do
    File.open("spec/fixtures/s_from_file.cfg","r") do |f|
      WmlAction::Section.new.fromFile(f)
    end
  end

end

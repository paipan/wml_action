require "wml_action"

describe WmlAction::ActionSection do

  it "Should load action section from a file" do
    File.open("spec/fixtures/as_from_file.cfg") do |f|
      WmlAction::ActionSection.new.fromFile(f)
    end

  end

end

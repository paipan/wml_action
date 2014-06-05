require "wml_action"

describe WmlAction::ActionSection do

  it "Should load action section from a file" do
    File.open("spec/fixtures/as_from_file.cfg") do |f|
      WmlAction::ActionSection.new.fromFile(f)
    end
  end

  it "should read tag" do
    File.open("spec/fixtures/tag.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      expect(s.subs.length).to eq 1
      expect(s.subs[0][:value].name).to eq "tag"
    end
  end

  it "should read inner tags" do
    File.open("spec/fixtures/inners.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      s=s.subs[0][:value]
      expect(s.subs.length).to eq 3
      expect(s.subs[0][:value].name).to eq "inner"
      expect(s.subs[1][:value].name).to eq "multitag"
      expect(s.subs[2][:value].name).to eq "multitag"
    end
  end

  it "should read attributes" do
    File.open("spec/fixtures/attributes.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      s=s.subs[0][:value]
      expect(s.keys.length).to eq 5
      expect(s.keys[0][:value]).to include "number"
      expect(s.keys[1][:value]).to include "plain"
      expect(s.keys[2][:value]).to include "macrosed"
      expect(s.keys[0][:value]["number"]).to eq "50"
      expect(s.keys[1][:value]["plain"]).to eq "One, Another"
      expect(s.keys[2][:value]["macrosed"]).to eq "{AMACRO}"
    end
  end

  it "should read string attributes" do
    File.open("spec/fixtures/strings.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      s=s.subs[0][:value]
      expect(s.keys.length).to eq 5
      expect(s.keys[0][:value]).to include "simple"
      expect(s.keys[1][:value]).to include "underscored"
      expect(s.keys[2][:value]).to include "multiline"
      expect(s.keys[3][:value]).to include "macrosed"
      expect(s.keys[0][:value]["simple"]).to eq ' "Hello"'
      expect(s.keys[1][:value]["underscored"]).to eq ' _ "Long Hello"'
      expect(s.keys[2][:value]["multiline"]).to eq  %( "This is \nvery long\nlong string")
      expect(s.keys[3][:value]["macrosed"]).to eq ' "This amount"+{AMOUNT}'
    end
  end

  it "should read macros" do
    File.open("spec/fixtures/macros.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      s=s.subs[0][:value]
      expect(s.macros.length).to eq 1
      expect(s.macros[0][:value]).to eq "{USEFUL_MACRO}"
    end
  end

  it "should read filters" do
    File.open("spec/fixtures/filter.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      s=s.subs[0][:value]
      expect(s.filter.length).to eq 1
      expect(s.filter).to include "type"
      expect(s.filter["type"]).to eq "flying"
    end
  end

  it "should read actions" do
    File.open("spec/fixtures/actions.cfg","r") do |f|
      s=WmlAction::ActionSection.new.fromFile(f)
      s=s.subs[0][:value]
      expect(s.macros.length).to eq 2
      expect(s.macros[0][:action]).to eq "+"
      expect(s.macros[0][:value]).to eq "{VARIABLES}"
      expect(s.macros[1][:action]).to eq "-"
      expect(s.macros[1][:value]).to eq "{ABILITIES}"
      expect(s.subs.length).to eq 2
      expect(s.subs[0][:action]).to eq "+"
      expect(s.subs[0][:value].name).to eq "attack"
      expect(s.subs[1][:action]).to eq "-"
      expect(s.subs[1][:value].name).to eq "resists"
    end
  end

end

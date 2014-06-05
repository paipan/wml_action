require 'wml_action'

describe WmlAction::Section do

  it "should have attribute struct" do
    a = WmlAction::Section::Attribute[:hp, 25]
    expect(a.name).to eq :hp
    expect(a.value).to eq 25
  end

  it "should add an attribute to a section" do
    s = WmlAction::Section.new( {name: "Unit"} )
    a = WmlAction::Section::Attribute[:hp, 25]
    s<<a
    expect(s.keys.size).to eq 1
    expect(s.keys).to include :hp
    expect(s.keys[:hp]).to eq 25
  end

  it "should have macro struct" do
    a = WmlAction::Section::Macro["SET_INVINCIBLE"]
    expect(a.value).to eq "SET_INVINCIBLE"
  end

  it "should add a macro to a section" do
    s = WmlAction::Section.new( {name: "Unit"} )
    a = WmlAction::Section::Macro["SET_INVINCIBLE"]
    s<<a
    expect(s.macros.size).to eq 1
    expect(s.macros).to include "SET_INVINCIBLE"
  end

  it "should add a subsection to a section" do
    s = WmlAction::Section.new( {name: "Unit"} )
    sub = WmlAction::Section.new( {name: "Attack"} )
    s<<sub
    expect(s.subs.size).to eq 1
    expect(s.subs).to include sub
  end

  context "from file" do

    it "should be created from file" do
      File.open("spec/fixtures/s_from_file.cfg","r") do |f|
        WmlAction::Section.new.fromFile(f)
      end
    end

    it "should read tag" do
      File.open("spec/fixtures/tag.cfg","r") do |f|
        s=WmlAction::Section.new.fromFile(f)
        expect(s.subs.length).to eq 1
        expect(s.subs[0].name).to eq "tag"
      end
    end

    it "should read inner tags" do
      File.open("spec/fixtures/inners.cfg","r") do |f|
        s=WmlAction::Section.new.fromFile(f)
        s=s.subs[0]
        expect(s.subs.length).to eq 3
        expect(s.subs[0].name).to eq "inner"
        expect(s.subs[1].name).to eq "multitag"
        expect(s.subs[2].name).to eq "multitag"
      end
    end

    it "should read atributes" do
      File.open("spec/fixtures/attributes.cfg","r") do |f|
        s=WmlAction::Section.new.fromFile(f)
        s=s.subs[0]
        expect(s.keys.length).to eq 3
        expect(s.keys).to include "number"
        expect(s.keys).to include "plain"
        expect(s.keys).to include "macrosed"
        expect(s.keys["number"]).to eq "50"
        expect(s.keys["plain"]).to eq "One, Another"
        expect(s.keys["macrosed"]).to eq "{AMACRO}"
      end
    end

    it "should read string attributes" do
      File.open("spec/fixtures/strings.cfg","r") do |f|
        s=WmlAction::Section.new.fromFile(f)
        s=s.subs[0]
        expect(s.keys.length).to eq 4
        expect(s.keys).to include "simple"
        expect(s.keys).to include "underscored"
        expect(s.keys).to include "multiline"
        expect(s.keys).to include "macrosed"
        expect(s.keys["simple"]).to eq " \"Hello\""
        expect(s.keys["underscored"]).to eq " _ \"Long Hello\""
        expect(s.keys["multiline"]).to eq  " \"This is \nvery long\nlong string\""
        expect(s.keys["macrosed"]).to eq " \"This amount\"+{AMOUNT}"
      end
    end

    it "should read macros" do
      File.open("spec/fixtures/macros.cfg","r") do |f|
        s=WmlAction::Section.new.fromFile(f)
        s=s.subs[0]
        expect(s.macros.length).to eq 1
        expect(s.macros[0]).to eq "{USEFUL_MACRO}"
      end
    end
  end

end

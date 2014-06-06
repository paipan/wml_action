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

end

require "wml_action"
require "debugger"

describe WmlAction::Document do

  it 'should read a tag' do
    d = WmlAction::Document.from_file('spec/fixtures/tag.cfg')
    puts d.to_s
    expect(d.root.subs.size).to eq 1
    expect(d.root.subs[0].name).to eq "tag"
  end

  it "should read inners" do
    d = WmlAction::Document.from_file('spec/fixtures/inners.cfg')
    s = d.root.subs[0]
    expect(s.subs.length).to eq 3
    expect(s.subs[0].name).to eq "inner"
    expect(s.subs[1].name).to eq "multitag"
    expect(s.subs[2].name).to eq "multitag"
  end

  it "should read numeric atributes" do
    d = WmlAction::Document.from_file('spec/fixtures/attributes.cfg')
    s = d.root.subs[0]
    expect(s.keys.length).to eq 3
    expect(s.keys).to include "number"
    expect(s.keys["number"]).to eq 50
    expect(s.keys).to include "plain"
    expect(s.keys["plain"]).to eq "One, Another"
    expect(s.keys).to include "macrosed"
    expect(s.keys["macrosed"]).to eq "{AMACRO}"
  end

  it "should read string attributes" do
    d = WmlAction::Document.from_file('spec/fixtures/strings.cfg')
    s = d.root.subs[0]
    expect(s.keys.length).to eq 5
    expect(s.keys).to include "simple"
    expect(s.keys).to include "underscored"
    expect(s.keys).to include "multiline"
    expect(s.keys).to include "macrosed"
    expect(s.keys["simple"]).to eq ' "Hello"'
    expect(s.keys["underscored"]).to eq ' _ "Long Hello"'
    expect(s.keys["multiline"]).to eq  " \"This is \nvery long\nlong string\""
    expect(s.keys["macrosed"]).to eq " \"This amount\"+{AMOUNT}"
  end

  it "should read macros" do
    d = WmlAction::Document.from_file('spec/fixtures/macros.cfg')
    s = d.root.subs[0]
    expect(s.macros.length).to eq 1
    expect(s.macros[0]).to eq "{USEFUL_MACRO}"
  end

end

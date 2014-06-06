require "wml_action"
require "debugger"

describe WmlAction::ActionDocument do

  it 'should read a tag' do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/tag.cfg')
    expect(d.root.subs.size).to eq 1
    expect(d.root.subs[0][:value].name).to eq "tag"
  end

  it "should read inners" do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/inners.cfg')
    s = d.root.subs[0][:value]
    expect(s.subs.length).to eq 3
    expect(s.subs[0][:value].name).to eq "inner"
    expect(s.subs[1][:value].name).to eq "multitag"
    expect(s.subs[2][:value].name).to eq "multitag"
  end

  it "should read atributes" do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/attributes.cfg')
    s = d.root.subs[0][:value]
    expect(s.keys.length).to eq 5
    expect(s.keys[0][:value]).to include "number"
    expect(s.keys[0][:value]["number"]).to eq 50
    expect(s.keys[1][:value]).to include "plain"
    expect(s.keys[1][:value]["plain"]).to eq "One, Another"
    expect(s.keys[2][:value]).to include "macrosed"
    expect(s.keys[2][:value]["macrosed"]).to eq "{AMACRO}"
    expect(s.keys[3][:value]).to include "likedigit"
    expect(s.keys[3][:value]["likedigit"]).to eq '0.1:0.2'
    expect(s.keys[4][:value]).to include "empty"
    expect(s.keys[4][:value]["empty"]).to eq ''
  end

  it "should read string attributes" do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/strings.cfg')
    s = d.root.subs[0][:value]
    expect(s.keys.length).to eq 5
    expect(s.keys[0][:value]).to include "simple"
    expect(s.keys[1][:value]).to include "underscored"
    expect(s.keys[2][:value]).to include "multiline"
    expect(s.keys[3][:value]).to include "macrosed"
    expect(s.keys[0][:value]["simple"]).to eq ' "Hello"'
    expect(s.keys[1][:value]["underscored"]).to eq ' _ "Long Hello"'
    expect(s.keys[2][:value]["multiline"]).to eq  " \"This is \nvery long\nlong string\""
    expect(s.keys[3][:value]["macrosed"]).to eq " \"This amount\"+{AMOUNT}"
  end

  it "should read macros" do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/macros.cfg')
    s = d.root.subs[0][:value]
    expect(s.macros.length).to eq 1
    expect(s.macros[0][:value]).to eq "{USEFUL_MACRO}"
  end

  it "should read filters" do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/filter.cfg')
    s = d.root.subs[0][:value]
    expect(s.filter.length).to eq 2
    expect(s.filter).to include "type"
    expect(s.filter["type"]).to eq "flying"
    expect(s.filter).to include "{FIRST_STRIKE}"
  end

  it "should read actions" do
    d = WmlAction::ActionDocument.from_file('spec/fixtures/actions.cfg')
    s = d.root.subs[0][:value]
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

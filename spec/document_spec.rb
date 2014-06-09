require "wml_action"
require "debugger"

module WMLAction

  describe Document do

    it 'should read a tag' do
      d = Document.from_file('spec/fixtures/tag.cfg')
      expect(d.root.name).to eq "tag"
    end

    it "should read inners" do
      d = Document.from_file('spec/fixtures/inners.cfg')
      s = d.root
      expect(s.subs.length).to eq 3
      expect(s.subs[0].name).to eq "inner"
      expect(s.subs[1].name).to eq "multitag"
      expect(s.subs[2].name).to eq "multitag"
    end

    it "should read atributes" do
      d = Document.from_file('spec/fixtures/attributes.cfg')
      s = d.root
      expect(s.keys.length).to eq 5
      expect(s.keys).to include "number"
      expect(s.keys["number"]).to eq 50
      expect(s.keys).to include "plain"
      expect(s.keys["plain"]).to eq "One, Another"
      expect(s.keys).to include "macrosed"
      expect(s.keys["macrosed"]).to eq "{AMACRO}"
      expect(s.keys).to include "likedigit"
      expect(s.keys["likedigit"]).to eq '0.1:0.2'
      expect(s.keys).to include "empty"
      expect(s.keys["empty"]).to eq ''
    end

    it "should read string attributes" do
      d = Document.from_file('spec/fixtures/strings.cfg')
      s = d.root
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
      d = Document.from_file('spec/fixtures/macros.cfg')
      s = d.root
      expect(s.macros).to include "{USEFUL_MACRO}"
    end

    it "should read filters" do
      d = Document.from_file('spec/fixtures/filter.cfg')
      s = d.root
      expect(s.filter.length).to eq 2
      expect(s.filter).to include "type"
      expect(s.filter["type"]).to eq "flying"
      expect(s.filter).to include "{FIRST_STRIKE}"
    end

    it "should read actions" do
      d = Document.from_file('spec/fixtures/actions.cfg')
      s = d.root
      expect(s.actions.length).to eq 4
      expect(s.actions).to include Section::Action[Section::Macro['{VARIABLES}'],'+']
      expect(s.actions).to include Section::Action[Section::Macro['{ABILITIES}'],'-']
      expect(s.actions[2].action).to eq "+"
      expect(s.actions[2].object.name).to eq "attack"
      expect(s.actions[3].action).to eq "-"
      expect(s.actions[3].object.name).to eq "resists"
    end

  end
end

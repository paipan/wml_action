require 'wml_action'
require 'debugger'

module WmlAction

  describe ActionSection do

    describe '#applyActionSection' do

      context 'when no action' do

        let(:actions) do
          a = ActionSection.new
          a << ActionSection::Attribute[:hp,25]
          a << ActionSection::Macro['{REGENERATE}']
          sub = ActionSection.new(name: 'attack')
          sub << ActionSection::Attribute[:type,'blunt']
          a << sub
          sub = ActionSection.new(name: 'resists')
          sub << ActionSection::Attribute[:cold,100]
          a << sub
          a
        end

        let(:target) do
          t = ActionSection.new
          t << ActionSection::Attribute[:hp,10]
          t << ActionSection.new(name: 'attack')
          t << ActionSection.new(name: 'attack')
          actions.applyActionSection(t)
          t
        end

        it 'adds an attribute' do
          expect(target.keys).to include :hp
        end

        it 'merges existing sections' do
          # TODO Should it works through check receiving messages?
          expect(target.subs[0].keys).to include :type
          expect(target.subs[1].keys).to include :type
        end

        it 'ignores new sections' do
          expect(target.subs[2]).to be_nil
        end

        it 'adds macros' do
          expect(target.macros).to include '{REGENERATE}'
        end

        it 'change an existing attribute' do
          expect(target.keys[:hp]).to eq 25
        end

      end

      context 'when + action' do

        let(:actions) do
          a = ActionSection.new
          sub = ActionSection.new(name: 'attack')
          sub << ActionSection::Attribute[:type,'blunt']
          a << ActionSection::Action[sub, '+']
          sub = ActionSection.new(name: 'resists')
          a << ActionSection::Action[sub, '+']
          a << ActionSection::Action[ActionSection::Macro['{REGENERATE}'], '+']
          a
        end

        let(:target) do
          t = ActionSection.new
          t << ActionSection.new(name: 'attack')
          actions.applyActionSection(t)
          t
        end

        it 'adds (existing) sections' do
          expect(target.subs[0].name).to eq 'attack'
          expect(target.subs[1].name).to eq 'attack'
        end

        it 'adds (new) sections' do
          expect(target.subs[2].name).to eq 'resists'
        end

        it 'adds macros' do
          expect(target.macros).to include '{REGENERATE}'
        end

      end

      context 'when - action' do

        let(:actions) do
          a = ActionSection.new
          sub = ActionSection.new(name: 'attack')
          a << ActionSection::Action[sub,'-']
          a << ActionSection::Action[ActionSection::Macro['{REGENERATE}'], '-']
          a
        end

        let(:target) do
          t = ActionSection.new
          t << ActionSection.new(name: 'attack')
          t << ActionSection::Macro['{REGENERATE}']
          actions.applyActionSection(t)
          t
        end

        it 'removes section' do
          expect(target.subs.size).to eq 0
        end

        it 'removes macros' do
          expect(target.macros).not_to include '{REGENERATE}'
        end

      end

      context 'when filtered section' do
        let(:actions) do
          a = ActionSection.new
          sub = ActionSection.new(name: 'attack')
          sub << ActionSection::Filter[:type,'blunt']
          sub << ActionSection::Attribute[:damage, 30]
          a << sub
          a
        end

        let(:target) do
          t = ActionSection.new
          sub = ActionSection.new(name: 'attack')
          sub << ActionSection::Attribute[:type,'blunt']
          sub << ActionSection::Attribute[:damage, 25]
          t << sub
          sub = ActionSection.new(name: 'attack')
          sub << ActionSection::Attribute[:type,'pierce']
          sub << ActionSection::Attribute[:damage, 25]
          t << sub
          actions.applyActionSection(t)
          t
        end

        it 'modifies matching section' do
          expect(target.subs[0].keys[:damage]).to eq 30
        end

        it 'ignores filtered section' do
          expect(target.subs[1].keys[:damage]).to eq 25
        end


      end


    end

    describe '#add and #<<' do

      it 'returns self' do
        s = ActionSection.new << ActionSection::Attribute[:hp,25]
        expect(s).to be_kind_of(ActionSection)
      end

    end

    describe '#match?' do
      it 'matches filter'
    end

    describe '#to_s' do
      let(:s) { ActionSection.new(name: 'unit') }

      it 'prints tags for section' do
        expect(s.to_s).to eq "[unit]\n[/unit]\n"
      end

      it 'prints attributes' do
        s << ActionSection::Attribute[:hp,25]
        s << ActionSection::Attribute[:race,'human']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\thp=25
        |\trace=human
        |[/unit]
        EOS
      end

      it 'prints macros' do
        s << ActionSection::Macro['{REGENERATES}']
        s << ActionSection::Macro['{INVISIBLE}']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t{REGENERATES}
        |\t{INVISIBLE}
        |[/unit]
        EOS
      end

      it 'prints sections' do
        s << ActionSection.new(name: 'attack')
        s << ActionSection.new(name: 'resists')
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t[attack]
        |\t[/attack]
        |\t[resists]
        |\t[/resists]
        |[/unit]
        EOS
      end

      it 'prints filters' do
        s << ActionSection::Filter[:hp,25]
        s << ActionSection::Filter[:race,'human']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t/ hp=25
        |\t/ race=human
        |[/unit]
        EOS
      end

      it 'prints actions' do
        s << ActionSection::Action[ActionSection.new(name: 'attack'),'+']
        s << ActionSection::Action[ActionSection::Macro['{REGENERATES}'],'-']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t+ [attack]
        |\t[/attack]
        |\t- {REGENERATES}
        |[/unit]
        EOS
      end

    end


  end

end

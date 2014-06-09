require 'wml_action'
require 'debugger'

module WMLAction

  describe Section do

    describe '#merge' do

      context 'when no action' do

        let(:actions) do
          a = Section.new
          a << Section::Attribute[:hp,25]
          a << Section::Macro['{REGENERATE}']
          sub = Section.new(name: 'attack')
          sub << Section::Attribute[:type,'blunt']
          a << sub
          sub = Section.new(name: 'resists')
          sub << Section::Attribute[:cold,100]
          a << sub
        end

        let(:target) do
          t = Section.new
          t << Section::Attribute[:hp,10]
          t << Section.new(name: 'attack')
          t << Section.new(name: 'attack')
          t.merge(actions)
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
          a = Section.new
          sub = Section.new(name: 'attack')
          sub << Section::Attribute[:type,'blunt']
          a << Section::Action[sub, '+']
          sub = Section.new(name: 'resists')
          a << Section::Action[sub, '+']
          a << Section::Action[Section::Macro['{REGENERATE}'], '+']
          a
        end

        let(:target) do
          t = Section.new
          t << Section.new(name: 'attack')
          t.merge(actions)
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
          a = Section.new
          sub = Section.new(name: 'attack')
          a << Section::Action[sub,'-']
          a << Section::Action[Section::Macro['{REGENERATE}'], '-']
        end

        let(:target) do
          t = Section.new
          t << Section.new(name: 'attack')
          t << Section::Macro['{REGENERATE}']
          t.merge(actions)
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
          a = Section.new
          sub = Section.new(name: 'attack')
          sub << Section::Filter[:type,'blunt']
          sub << Section::Attribute[:damage, 30]
          a << sub
        end

        let(:target) do
          t = Section.new
          sub = Section.new(name: 'attack')
          sub << Section::Attribute[:type,'blunt']
          sub << Section::Attribute[:damage, 25]
          t << sub
          sub = Section.new(name: 'attack')
          sub << Section::Attribute[:type,'pierce']
          sub << Section::Attribute[:damage, 25]
          t << sub
          t.merge(actions)
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
        s = Section.new << Section::Attribute[:hp,25]
        expect(s).to be_kind_of(Section)
      end

    end

    describe '#match?' do
      it 'matches filter'
    end

    describe '#to_s' do
      let(:s) { Section.new(name: 'unit') }

      it 'prints tags for section' do
        expect(s.to_s).to eq "[unit]\n[/unit]\n"
      end

      it 'prints attributes' do
        s << Section::Attribute[:hp,25]
        s << Section::Attribute[:race,'human']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\thp=25
        |\trace=human
        |[/unit]
        EOS
      end

      it 'prints macros' do
        s << Section::Macro['{REGENERATES}']
        s << Section::Macro['{INVISIBLE}']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t{REGENERATES}
        |\t{INVISIBLE}
        |[/unit]
        EOS
      end

      it 'prints sections' do
        s << Section.new(name: 'attack')
        s << Section.new(name: 'resists')
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
        s << Section::Filter[:hp,25]
        s << Section::Filter[:race,'human']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t/ hp=25
        |\t/ race=human
        |[/unit]
        EOS
      end

      it 'prints actions' do
        s << Section::Action[Section.new(name: 'attack'),'+']
        s << Section::Action[Section::Macro['{REGENERATES}'],'-']
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

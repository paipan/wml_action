require 'wml_action'
require 'debugger'

module WMLAction

  describe Tag do

    describe '#merge' do

      context 'when no action' do

        let(:actions) do
          a = Tag.new
          a << Tag::Attribute[:hp,25]
          a << Tag::Macro['{REGENERATE}']
          sub = Tag.new(name: 'attack')
          sub << Tag::Attribute[:type,'blunt']
          a << sub
          sub = Tag.new(name: 'resists')
          sub << Tag::Attribute[:cold,100]
          a << sub
        end

        let(:target) do
          t = Tag.new
          t << Tag::Attribute[:hp,10]
          t << Tag.new(name: 'attack')
          t << Tag.new(name: 'attack')
          t.merge(actions)
        end

        it 'adds an attribute' do
          expect(target.attrs).to include :hp
        end

        it 'merges existing sections' do
          # TODO Should it works through check receiving messages?
          expect(target.subs[0].attrs).to include :type
          expect(target.subs[1].attrs).to include :type
        end

        it 'ignores new sections' do
          expect(target.subs[2]).to be_nil
        end

        it 'adds macros' do
          expect(target.macros).to include '{REGENERATE}'
        end

        it 'change an existing attribute' do
          expect(target.attrs[:hp]).to eq 25
        end

      end

      context 'when + action' do

        let(:actions) do
          a = Tag.new
          sub = Tag.new(name: 'attack')
          sub << Tag::Attribute[:type,'blunt']
          a << Tag::Action[sub, '+']
          sub = Tag.new(name: 'resists')
          a << Tag::Action[sub, '+']
          a << Tag::Action[Tag::Macro['{REGENERATE}'], '+']
          a
        end

        let(:target) do
          t = Tag.new
          t << Tag.new(name: 'attack')
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
          a = Tag.new
          sub = Tag.new(name: 'attack')
          a << Tag::Action[sub,'-']
          a << Tag::Action[Tag::Macro['{REGENERATE}'], '-']
        end

        let(:target) do
          t = Tag.new
          t << Tag.new(name: 'attack')
          t << Tag::Macro['{REGENERATE}']
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
          a = Tag.new
          sub = Tag.new(name: 'attack')
          sub << Tag::Filter[:type,'blunt']
          sub << Tag::Attribute[:damage, 30]
          a << sub
        end

        let(:target) do
          t = Tag.new
          sub = Tag.new(name: 'attack')
          sub << Tag::Attribute[:type,'blunt']
          sub << Tag::Attribute[:damage, 25]
          t << sub
          sub = Tag.new(name: 'attack')
          sub << Tag::Attribute[:type,'pierce']
          sub << Tag::Attribute[:damage, 25]
          t << sub
          t.merge(actions)
        end

        it 'modifies matching section' do
          expect(target.subs[0].attrs[:damage]).to eq 30
        end

        it 'ignores filtered section' do
          expect(target.subs[1].attrs[:damage]).to eq 25
        end


      end


    end

    describe '#add and #<<' do

      it 'returns self' do
        s = Tag.new << Tag::Attribute[:hp,25]
        expect(s).to be_kind_of(Tag)
      end

    end

    describe '#match?' do
      it 'matches filter'
    end

    describe '#to_s' do
      let(:s) { Tag.new(name: 'unit') }

      it 'prints tags for section' do
        expect(s.to_s).to eq "[unit]\n[/unit]\n"
      end

      it 'prints attributes' do
        s << Tag::Attribute[:hp,25]
        s << Tag::Attribute[:race,'human']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\thp=25
        |\trace=human
        |[/unit]
        EOS
      end

      it 'prints macros' do
        s << Tag::Macro['{REGENERATES}']
        s << Tag::Macro['{INVISIBLE}']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t{REGENERATES}
        |\t{INVISIBLE}
        |[/unit]
        EOS
      end

      it 'prints sections' do
        s << Tag.new(name: 'attack')
        s << Tag.new(name: 'resists')
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
        s << Tag::Filter[:hp,25]
        s << Tag::Filter[:race,'human']
        expect(s.to_s).to eq <<-EOS.gsub(/^\s+\|/, '')
        |[unit]
        |\t/ hp=25
        |\t/ race=human
        |[/unit]
        EOS
      end

      it 'prints actions' do
        s << Tag::Action[Tag.new(name: 'attack'),'+']
        s << Tag::Action[Tag::Macro['{REGENERATES}'],'-']
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

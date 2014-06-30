require 'wml_action'
require 'debugger'

module WMLAction

  describe Tag::Expr do

    before(:all) do
        Expr=Tag::Expr unless WMLAction.const_defined? 'Expr'
        Var=Tag::Expr::Var unless WMLAction.const_defined? 'Var'
        Op=Tag::Expr::Op unless WMLAction.const_defined? 'Op'
    end

    describe '#result' do

        it 'sums numbers' do
            e=Expr[1,2,Op['+']]
            expect(e.result).to eq 3
        end

        it 'substract numbers' do
            e=Expr[2,1,Op['-']]
            expect(e.result).to eq 1
        end

        it 'multiply numbers' do
            e=Expr[2,3,Op['*']]
            expect(e.result).to eq 6
        end

        it 'multiply numbers' do
            e=Expr[6,3,Op['/']]
            expect(e.result).to eq 2
        end

        it 'more than one operation' do
            e=Expr[2,3,Op['*'],3,Op['-']]
            expect(e.result).to eq 3
        end

        it 'results in integers' do
            e=Expr[6,4,Op['/']]
            expect(e.result).to be_integer
        end

        it 'substitute variables' do
            e=Expr[Var[:a],Var[:b],Op['+']]
            expect(e.result({a: 1, b: 3})).to eq 4
        end

        it 'returns empty string on empty expr' do
            e=Expr[]
            expect(e.result).to eq ''
        end

        context 'when operates with strings' do

            it 'concatenates strings' do
                e=Expr['Hello',' World!',Op['+']]
                expect(e.result).to eq 'Hello World!'
            end

            it 'keeps quotes in strings operations' do
                pending('Probably should implement this feature by intorducing new operation')
                e=Expr[%Q("Hello"),' World!',Op['+']]
                expect(e.result).to eq %Q("Hello World!")
            end

        end

        context 'when invalid expression' do

            it 'raises syntax error on error with binary op' do
                e=Expr[1,Op['+']]
                expect { e.result }.to raise_error
            end

            it 'raises syntax error on error with lack of op' do
                e=Expr[1,2]
                expect { e.result }.to raise_error
            end

        end

    end

    describe '#dump' do
        it 'dumps expr to string' do
            e=Expr[Var['hp'],1,Op['+'],2,Op['*']]
            expect(e.dump).to eq 'hp 1 + 2 *'
        end
    end

    describe '#to_s' do
        it 'pretty prints for wml file output' do
            pending('Do not think I need this feature')
            e=Expr[Var['hp'],1,Op['+'],2,Op['*']]
            expect(e.to_s).to eq '(hp+1)*2'
        end
    end

  end
end

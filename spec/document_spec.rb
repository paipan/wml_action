require "wml_action"

describe WmlAction::Document do

  it 'should read a tag' do
    d = WmlAction::Document.from_file('spec/fixtures/tag.cfg')
    puts d.to_s
    expect(d.root.subs.size).to eq 1
    expect(d.root.subs[0].name).to eq "tag"
  end

  it "should read inners" do
    d = WmlAction::Document.from_file('spec/fixtures/inners.cfg')
    d=d.subs[0]
    expect(d.root.subs.length).to eq 3
    expect(d.root.subs[0].name).to eq "inner"
    expect(d.root.subs[1].name).to eq "multitag"
    expect(d.root.subs[2].name).to eq "multitag"
  end

end

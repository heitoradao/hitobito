require 'spec_helper'

describe TableDisplay do
  let(:person) { people(:top_leader) }
  let(:group)  { groups(:top_layer) }
  let(:event)  { events(:top_event) }

  it 'initializes TableDisplay::Group for group parent' do
    subject = TableDisplay.for(person, group)
    expect(subject).to be_instance_of(TableDisplay::People)
  end

  it 'initializes TableDisplay::Event for event parent' do
    subject = TableDisplay.for(person, event)
    expect(subject).to be_instance_of(TableDisplay::Participations)
  end

  skip 'initializes selected to defaults' do
    subject = TableDisplay.for(person, group)
    expect(subject.selected).not_to be_empty
    expect(subject.selected).to eq subject.defaults
  end

  it 'allows resetting selected columns' do
    subject = TableDisplay.for(person, event)
    subject.save!
    subject.update(selected: [])
    expect(subject.selected).not_to be_present
  end
end

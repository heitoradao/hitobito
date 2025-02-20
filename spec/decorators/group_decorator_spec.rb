# frozen_string_literal: true

#  Copyright (c) 2012-2021, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe GroupDecorator, :draper_with_helpers do
  include Rails.application.routes.url_helpers

  let(:context) { double('context') }
  let(:model) { groups(:top_group) }

  subject { GroupDecorator.new(model) }

  describe 'possible roles' do
    its(:possible_roles) do
      should eq [Group::TopGroup::Leader,
                 Group::TopGroup::LocalGuide,
                 Group::TopGroup::Secretary,
                 Group::TopGroup::LocalSecretary,
                 Group::TopGroup::Member,
                 Role::External]
    end
  end

  describe 'selecting attributes' do

    class DummyGroup < Group
      self.used_attributes += [:foo, :bar]
    end

    let(:model) { DummyGroup.new }

    before do
      allow(subject).to receive_messages(h: context)
    end

    it '#used_attributes selects via .attr_used?' do
      expect(subject.used_attributes(:foo, :bar)).to eq %w(foo bar)
    end

    it '#modifiable_attributes we can :modify_superior' do
      expect(context).to receive(:can?).with(:modify_superior, subject).and_return(true)
      expect(subject.modifiable_attributes(:foo, :bar)).to eq %w(foo bar)
    end

    it '#modifiable_attributes filters attributes if we cannot :modify_superior' do
      allow(model.class).to receive_messages(superior_attributes: [:foo])
      expect(context).to receive(:can?).with(:modify_superior, subject).and_return(false)
      expect(subject.modifiable_attributes(:foo, :bar)).to eq %w(bar)
    end

    it '#modifiable? we can :modify_superior' do
      expect(context).to receive(:can?).with(:modify_superior, subject).and_return(true)
      expect(subject.modifiable?(:foo) { |val| val }).to eq %w(foo)
    end

    it '#modifiable? filters attributes if we cannot :modify_superior' do
      allow(model.class).to receive_messages(superior_attributes: [:foo])
      expect(context).to receive(:can?).with(:modify_superior, subject).and_return(false)
      expect(subject.modifiable_attributes(:foo) { |val| val }).to eq %w()
    end
  end

  describe 'subgroups' do
    let(:model) { groups(:bottom_layer_one) }

    its(:subgroup_ids) do
      should match_array(
        [ groups(:bottom_layer_one),
          groups(:bottom_group_one_one),
          groups(:bottom_group_one_one_one),
          groups(:bottom_group_one_two)
        ].collect(&:id))
    end
  end

  context 'archived groups' do
    let(:model) do
      groups(:bottom_group_one_two).tap { |g| g.update(archived_at: 1.day.ago) }
    end

    it 'suffix to_s' do
      expect(subject.to_s).to end_with(' (archiviert)')
    end

    it 'suffix to_s with argument' do
      expect(subject.to_s(:default)).to end_with(' (archiviert)')
    end

    it 'suffix to_s with argument' do
      expect(subject.to_s(:long_format)).to end_with(' (archiviert)')
    end

    it 'suffix display_name' do
      expect(subject.display_name).to end_with(' (archiviert)')
    end
  end

  context 'not archived groups' do
    let(:model) do
      groups(:bottom_group_one_two).tap { |g| g.update(archived_at: nil) }
    end

    it 'suffix to_s' do
      expect(subject.to_s).to_not end_with(' (archiviert)')
    end

    it 'suffix to_s with argument' do
      expect(subject.to_s(:default)).to_not end_with(' (archiviert)')
    end

    it 'suffix to_s with argument' do
      expect(subject.to_s(:long_format)).to_not end_with(' (archiviert)')
    end

    it 'suffix display_name' do
      expect(subject.display_name).to_not end_with(' (archiviert)')
    end
  end
end

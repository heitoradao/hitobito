# encoding: utf-8

#  Copyright (c) 2012-2014, Jungwacht Blauring Schweiz, Pfadibewegung Schweiz.
#  This file is part of hitobito and licensed under the Affero General Public
#  License version 3 or later. See the COPYING file at the top-level
#  directory or at https://github.com/hitobito/hitobito.


require 'spec_helper'


describe RolesController, js: true do

  subject { page }
  let(:group) { groups(:top_group) }
  let!(:role1)  { Fabricate(Group::TopGroup::Member.name.to_sym, group: group) }
  let!(:role2)  { Fabricate(Group::TopGroup::Member.name.to_sym, group: group) }
  let!(:leader) { Fabricate(Group::TopGroup::Leader.name.to_sym, group: group) }

  it 'toggles people fields' do
    obsolete_node_safe do
      skip 'expected to find visible css "#role_person" but there were no matches'
      sign_in
      visit new_group_role_path(group_id: group.id)
      is_expected.to have_content('Person hinzufügen')
      is_expected.to have_selector('#role_person', visible: true)
      is_expected.to have_selector('#role_new_person_first_name', visible: false)

      click_link('Neue Person erfassen')
      is_expected.to have_selector('#role_person', visible: false)
      is_expected.to have_selector('#role_new_person_first_name', visible: true)

      click_link('Bestehende Person suchen')
      is_expected.to have_selector('#role_person', visible: true)
      is_expected.to have_selector('#role_new_person_first_name', visible: false)
    end
  end

  it 'uses exisiting person when given' do
    obsolete_node_safe do
      sign_in
      visit new_group_role_path(group_id: group.id)

      find('#role_type_select a.chosen-single').click
      find('#role_type_select ul.chosen-results').find('li', text: 'Leader').click

      # test user clicking around first
      click_link('Neue Person erfassen')
      fill_in('Vorname', with: 'Tester')

      # now search existing person
      click_link('Bestehende Person suchen')
      fill_in 'Person', with: 'Top'
      page.find('.typeahead.dropdown-menu li').click

      all('form .btn-toolbar').first.click_button 'Speichern'

      expect(current_path).to eq(group_people_path(group))
      is_expected.to have_content 'Rolle Leader für Top Leader in TopGroup wurde erfolgreich erstellt.'
    end
  end

  it 'creates new person when fields filled' do
    obsolete_node_safe do
      sign_in
      visit new_group_role_path(group_id: group.id)

      find('#role_type_select a.chosen-single').click
      find('#role_type_select ul.chosen-results').find('li', text: 'Leader').click

      # test user clicking around first
      fill_in 'Person', with: 'Top'
      sleep(0.5)
      find('.typeahead.dropdown-menu li').click

      # now define new person
      click_link('Neue Person erfassen')
      fill_in('Vorname', with: 'Tester')

      all('form .btn-toolbar').first.click_button 'Speichern'

      expect(current_path).not_to eq(group_people_path(group))
      is_expected.to have_content 'Rolle Leader für Tester in TopGroup wurde erfolgreich erstellt.'
    end
  end

  it 'updates info when type changes' do
    obsolete_node_safe do
      sign_in
      visit new_group_role_path(group_id: group.id)

      find('#role_type_select a.chosen-single').click
      find('#role_type_select ul.chosen-results').find('li', text: 'Leader').click

      expect(find('#role_info')).to have_content('Die Rolle Leader in der Gruppe TopGroup')

      find('#role_type_select a.chosen-single').click
      find('#role_type_select ul.chosen-results').find('li', text: 'Member').click

      expect(find('#role_info')).to have_content('Die Rolle Member in der Gruppe TopGroup')
    end
  end

  it 'updates role types when group changes' do
    obsolete_node_safe do
      sign_in
      visit new_group_role_path(group_id: group.id)

      # fill person
      fill_in 'Person', with: 'Top'
      page.find('.typeahead.dropdown-menu li').click

      expect(all('#role_group_id option', visible: false).size).to eq(3)
      expect(all('#role_type option', visible: false).size).to eq(7)

      # select role that will be discarded
      find('#role_type_select a.chosen-single').click
      find('#role_type_select ul.chosen-results').find('li', text: 'Leader').click

      # select group
      find('#role_group_id_chosen a.chosen-single').click
      find('#role_group_id_chosen ul.chosen-results').find('li', text: 'Toppers').click

      expect(find('#role_type_chosen .chosen-single span')).to have_content('Bitte auswählen')
      expect(all('#role_type option', visible: false).size).to eq(4)

      # select role
      find('#role_type_select a.chosen-single').click
      find('#role_type_select ul.chosen-results').find('li', text: 'Member').click

      expect(find('#role_info')).to have_content('Die Rolle Member in der Gruppe Toppers')

      # save
      all('form .btn-toolbar').first.click_button 'Speichern'

      expect(current_path).to eq(group_people_path(groups(:toppers)))
      is_expected.to have_content 'Rolle Member für Top Leader in Toppers wurde erfolgreich erstellt.'
    end
  end

  it 'updates person role with popupmenu' do
    obsolete_node_safe do
      sign_in

      # Add additional role to first person
      visit group_people_path(group_id: group.id)
      find(:css, "#ids_[value='#{role1.person.id}']").set(true)
      find(:css, "#ids_[value='#{role2.person.id}']").set(true)

      click_link('Rolle hinzufügen')

      select('Leader', from: 'role_type')
      expect(page).to have_button '2 Rollen erstellen'
      find('button', text: '2 Rollen erstellen').click

      is_expected.to have_content('2 Rollen wurden erstellt')
      is_expected.to have_css("tr#person_#{role1.person.id} td p", text: 'Leader')
      is_expected.to have_css("tr#person_#{role2.person.id} td p", text: 'Leader')

      person_with_two_roles = role1.person
      person_with_two_roles_row = find("tr#person_#{person_with_two_roles.id}")

      # Expect to have people table with person above
      is_expected.to have_selector('div.table-responsive')
      is_expected.to have_css("tr#person_#{person_with_two_roles.id} td p", text: 'Leader')
      is_expected.to have_css("tr#person_#{person_with_two_roles.id} td p", text: 'Member')

      # Click person row to alter role of person and expect role popup
      person_with_two_roles_row.find_all("a[title=\"Bearbeiten\"]").first.click
      is_expected.to have_css("div.popover")

      # Change role
      find("div.popover div#role_type_select").click
      is_expected.to have_css("div.popover div.chosen-drop", visible: true)

      role_select_menu = find("div.popover div.chosen-drop", visible: true)
      expect(role_select_menu).to have_content('Leader')

      role_select_menu.find_all("li").last.click

      # Click save
      find("button[data-disable-with=\"Speichern\"]").click

      # Expect role Leader and External
      is_expected.to have_css("tr#person_#{person_with_two_roles.id} td p", text: 'Leader')
      is_expected.to have_css("tr#person_#{person_with_two_roles.id} td p", text: 'External')

      # Expect role field to have no more roles than person has in db
      person_db_role_count = person_with_two_roles.roles.count
      expect(person_with_two_roles_row.find_all("td[style=\"display: table-cell;\"] > p").count).to eq(person_db_role_count)
    end
  end
end

# frozen_string_literal: true

#  Copyright (c) 2012-2021, Die Mitte Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class People::HouseholdList
  include Enumerable

  def initialize(people_scope)
    @people_scope = people_scope
  end

  def people_without_household
    @people_scope.where(household_key: nil)
  end

  def grouped_households
    people = Person.quoted_table_name

    # remove previously added selects, very important to make this query scale
    @people_scope.unscope(:select, :includes).
        # group by household, but keep NULLs separate
        select("IFNULL(#{people}.`household_key`, #{people}.`id`) as `key`").
        # Must select the primary key column because find_in_batches needs it for sorting.
        select("MIN(#{Person.quoted_table_name}.`id`) as `id`").
        select("COUNT(#{people}.`household_key`) as `count`").
        group(:key)
  end

  def households_in_batches(exclude_non_households: false)
    return unless block_given?
    base_scope = exclude_non_households ? only_households : grouped_households

    # When limiting the number of rows, make sure to always show some households.
    # For this, we override the order that find_in_batches uses. By default, it
    # always orders by the primary key column ascendingly.
    def base_scope.batch_order
      [Arel::Nodes::SqlLiteral.new('`count`').desc, super]
    end

    base_scope.find_in_batches(batch_size: 300) do |batch|
      involved_people = fetch_people_with_id_or_household_key(batch.map(&:key))
      grouped_people = batch.map do |household|
        involved_people.select do |person|
          # the 'key' is either a household key or a single person id
          person.household_key == household.key || person.id.to_s == household.key
        end
      end
      yield grouped_people
    end
  end

  def each(exclude_non_households: false, &block)
    return to_enum(:each) unless block_given?

    households_in_batches(exclude_non_households: exclude_non_households) do |batch|
      batch.each(&block)
    end
  end

  private

  def only_households
    grouped_households.where.not(household_key: nil)
  end

  def fetch_people_with_id_or_household_key(keys_or_ids)
    # Search for any number of housemates, regardless of preview limit
    base_scope = @people_scope.unscope(:limit)
    # Make sure to select household_key if we aren't selecting specific columns
    base_scope = base_scope.select(:household_key) if base_scope.select_values.present?

    base_scope.where(household_key: keys_or_ids).
        or(base_scope.where(id: keys_or_ids)).
        load
  end

end

class Event::ListsController < ApplicationController
  include YearBasedPaging
  
  attr_reader :group_id
  helper_method :group_id

  skip_authorize_resource only: [:events, :courses]


  def events
    authorize!(:index, Event)
    group_ids = current_user.groups_hierarchy_ids
      
    events = Event.upcoming.
                   with_group_id(group_ids).
                   includes(:dates, :groups).
                   where('events.type != ? OR events.type IS NULL', Event::Course.sti_name).
                   order('event_dates.finish_at ASC')
                  
    @events_by_month = EventDecorator.decorate(events).group_by do |entry|
      if entry.dates.present?
        l(entry.dates.first.start_at, format: :month_year)
      else
        "Ohne Datumsangabe"
      end
    end
  end

  def courses
    authorize!(:index, Event::Course)
    set_group_vars
    scope = Event::Course.order('event_kinds.id').in_year(year).list
    courses = EventDecorator.decorate(limit_scope_for_user(scope))
    @courses_by_kind = courses.group_by { |entry| entry.kind.label }
    @courses_by_kind.each do |kind, entries| 
      entries.sort_by! {|e| e.dates.first.try(:start_at) || Time.zone.now }.
              collect! {|e| EventDecorator.new(e) }
    end
  end

  private
  
  def set_group_vars
    if can?(:manage_courses, current_user)
      # assign default group on initial request
      unless params[:year].present? 
        params[:group] = (Group.course_offerers_in_hierarchy(current_user) - [Group.root.id]).first
      end 
      @group_id = params[:group].to_i 
    end

  end

  def limit_scope_for_user(scope)
    if can?(:manage_courses, current_user)
      group_id > 0 ? scope.with_group_id(group_id) : scope
    else
      scope.in_hierarchy(current_user)
    end
  end

end

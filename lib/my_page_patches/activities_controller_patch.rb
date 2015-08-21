module MyPagePatches
  module ActivitiesControllerPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        helper :issues
        alias_method_chain :index, :esi
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def index_with_esi
        if Setting.plugin_redmine_my_page["my_activity_enable"] == "1"
          @days = Setting.activity_days_default.to_i

          if params[:from]
            begin; @date_to = params[:from].to_date + 1; rescue; end
          end

          @date_to ||= Date.today + 1
          @date_from = @date_to - @days
          @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
          if params[:user_id].present?
            @author = User.active.find_by_id(params[:user_id])
          end

          @activity = Redmine::Activity::Fetcher.new(User.current, :project => @project,
                                                                   :with_subprojects => @with_subprojects,
                                                                   :author => @author)
          @activity.scope_select {|t| !params["show_#{t}"].nil?}
          @activity.scope = (@author.nil? ? :default : :all) if @activity.scope.empty?

          events = @activity.events(@date_from, @date_to)

          # Optional filtering by a custom query identifier parameter
          @filter_title = nil
          if params[:query_id].present?
            logger.debug("Query ID : #{params[:query_id]}")
            query = Query.find(params[:query_id])
            if query
              issue_filter = Issue.joins(:status, :project).where(query.statement).to_a

              filtered = Array.new
              events.each do |e|
                if (e.is_a?(Journal) && issue_filter.include?(e.issue)) ||
                   (e.is_a?(Issue)   && issue_filter.include?(e)) ||
                   (e.is_a?(TimeEntry) && issue_filter.include?(e.issue)) ||
                   (e.is_a?(Changeset) && e.issues.to_a.any?{ |x| issue_filter.include?(x)} )
                  filtered << e
                end
              end
              events = filtered
              @filter_title = query.name
            end
          end

          if events.empty? || stale?(:etag => [@activity.scope, @date_to, @date_from, @with_subprojects, @author, events.first, events.size, User.current, current_language])
            respond_to do |format|
              format.html {
                @events_by_day = events.group_by {|event| User.current.time_to_date(event.event_datetime)}
                if request.xhr?
                  render :template => 'activities/esi', :layout => false
                else
                  render :template => 'activities/esi'
                end
              }
              format.atom {
                title = l(:label_activity)
                if @author
                  title = @author.name
                elsif @activity.scope.size == 1
                  title = l("label_#{@activity.scope.first.singularize}_plural")
                end
                render_feed(events, :title => "#{@project || Setting.app_title}: #{title}")
              }
            end
          end
        else
          index_without_esi
        end
      end
    end
  end
end


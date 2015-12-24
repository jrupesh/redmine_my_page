require_dependency 'sort_helper'

module MyPagePatches
  module MyControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        helper :sort
        base.send(:include, SortHelper)
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def my_custom_form
        @user = User.current
        @object = params[:object]
        @pref = @user.pref

        if @object == 'dashboard'
          @dashboard = Dashboard.find_by_id(params[:dashboard_id])
          deny_access unless @dashboard && @dashboard.manage_layout?(@user)
        end
        if params["type"].present? && params["type"] == 'my_cust_query'
          @vartype = "my_cust_query"
          @my_cust_query = @object == 'dashboard' ? @dashboard.my_cust_query : @pref.my_cust_query
        else
          @vartype = "my_activity"
          @my_cust_query = @object == 'dashboard' ? @dashboard.my_activity : @pref.my_activity
        end

        visible_queries_array = IssueQuery.visible.
            order("#{Project.table_name}.name ASC", "#{Query.table_name}.name ASC").
            pluck(:name, :id, "projects.name").to_a

        @visible_queries = visible_queries_array.collect { |name, id, projectname| ["#{projectname.blank? ? "" : projectname + " - "}#{name}", id ] }
      end

      def update_queries
        @object = params[:object]
        if @object == 'dashboard'
          @dashboard              = Dashboard.find_by_id(params[:dashboard_id])
          deny_access unless @dashboard && @dashboard.manage_layout?(User.current)
          if params["my_cust_query"].present?
            dashboard_pref              = @dashboard.my_cust_query
            dashboard_pref[:limit]      = params["my_cust_query"]["limit"] || 10
            dashboard_pref[:query_ids]  = params["my_cust_query"]["query_ids"].any? ? params["my_cust_query"]["query_ids"].collect { |i| i.to_i } : []
            @dashboard.save
          elsif params["my_activity"].present?
            dashboard_pref              = @dashboard.my_activity
            dashboard_pref[:query_ids]  = params["my_activity"]["query_ids"].any? ? params["my_activity"]["query_ids"].collect { |i| i.to_i } : []
            @dashboard.save
          end
          redirect_to dashboards_path( :id => @dashboard.id )
        else
          if params["my_cust_query"].present?
            @user_pref              = User.current.pref.my_cust_query
            @user_pref[:limit]      = params["my_cust_query"]["limit"] || 10
            @user_pref[:query_ids]  = params["my_cust_query"]["query_ids"].any? ? params["my_cust_query"]["query_ids"].collect { |i| i.to_i } : []
            User.current.pref.save
          elsif params["my_activity"].present?
            @user_pref              = User.current.pref.my_activity
            @user_pref[:query_ids]  = params["my_activity"]["query_ids"].any? ? params["my_activity"]["query_ids"].collect { |i| i.to_i } : []
            User.current.pref.save
          end
          redirect_to my_page_path
        end
      end
    end
  end
end


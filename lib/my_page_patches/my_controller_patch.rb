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
        @pref = @user.pref

        visible_queries_array = if IssueQuery.respond_to? (:esi_visible_queries)
          IssueQuery.esi_visible_queries.
            order("#{Project.table_name}.name ASC", "#{Query.table_name}.name ASC").
            pluck(:name, :id, "projects.name").to_a
        else
          IssueQuery.visible.
            order("#{Project.table_name}.name ASC", "#{Query.table_name}.name ASC").
            pluck(:name, :id, "projects.name").to_a
        end
        @visible_queries = visible_queries_array.collect { |name, id, projectname| ["#{projectname.blank? ? "" : projectname + " - "}#{name}", id ] }

        if params["type"].present? && params["type"] == 'my_cust_query'
          @vartype = "my_cust_query"
          @my_cust_query = @pref.my_cust_query
        else
          @vartype = "my_activity"
          @my_cust_query = @pref.my_activity
        end
      end

      def update_queries
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


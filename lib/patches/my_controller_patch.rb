module Patches
  module MyControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def my_custom_form
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

        @vartype = if params["type"].present? && params["type"] == 'my_cust_query'
          "my_cust_query"
        else
          "my_activity"
        end

        @my_cust_query = User.current.pref[:others][@vartype]
        if @my_cust_query.nil?
          user = User.current
          user.pref[:others][@vartype] = Hash.new
          user.pref[:others][@vartype][:query_ids]= []
          user.pref[:others][@vartype][:limit]= 10
          user.pref.save
          @my_cust_query = User.current.pref[:others][@vartype]
        end

      end

      def update_queries
        if params["my_cust_query"].present?
          @user_pref                                        = User.current.pref
          @user_pref[:others]["my_cust_query"][:limit]      = params["my_cust_query"]["limit"] || 10
          @user_pref[:others]["my_cust_query"][:query_ids]  = params["my_cust_query"]["query_ids"].any? ? params["my_cust_query"]["query_ids"].collect { |i| i.to_i } : []
          @user_pref.save
        elsif params["my_activity"].present?
          @user_pref                                        = User.current.pref
          @user_pref[:others]["my_activity"][:limit]      = params["my_activity"]["limit"] || 10
          @user_pref[:others]["my_activity"][:query_ids]  = params["my_activity"]["query_ids"].any? ? params["my_activity"]["query_ids"].collect { |i| i.to_i } : []
          @user_pref.save
        end
        redirect_to my_page_path
      end
    end
  end
end


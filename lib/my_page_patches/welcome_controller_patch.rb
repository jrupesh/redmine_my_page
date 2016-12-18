module MyPagePatches
  module WelcomeControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :landing_page_index, :only => :index
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def landing_page_index
        @pref = User.current.pref
        return if @pref.landing_page.nil? || @pref.landing_page.blank?
        if @pref.landing_page.start_with?('o-')
          redirect_to project_path( :id => @pref.landing_page.gsub("o-","").to_i )
        elsif @pref.landing_page.start_with?('p-')
          home_project = Project.find_by_id(@pref.landing_page.gsub("p-","").to_i)
          return if home_project.nil? || home_project.archived?
          redirect_to issues_path( :project_id => home_project.id )
        elsif @pref.landing_page.start_with?('q-')
          query_id = @pref.landing_page.gsub("q-","").to_i
          query = IssueQuery.find_by_id(query_id)
          return if query.nil?
          param_hash = query.project_id.nil? ? { :query_id => query_id } : { :project_id => query.project_id, :query_id => query_id }
          redirect_to issues_path( param_hash )
        elsif Redmine::Plugin.installed?(:redmine_agile)
          if @pref.landing_page.start_with?('ap-')
            home_project = Project.find_by_id(@pref.landing_page.gsub("ap-","").to_i)
            return if home_project.nil? || home_project.archived?
            redirect_to agile_board_path( :project_id => home_project.id )
          elsif @pref.landing_page.start_with?('aq-')
            query_id = @pref.landing_page.gsub("aq-","").to_i
            query = AgileQuery.find_by_id(query_id)
            return if query.nil?
            param_hash = query.project_id.nil? ? { :query_id => query_id } : { :project_id => query.project_id, :query_id => query_id }
            redirect_to agile_board_path( param_hash )
          end
        elsif @pref.landing_page.start_with?('my_page')
          redirect_to my_page_path
        end
      end
    end
  end
end
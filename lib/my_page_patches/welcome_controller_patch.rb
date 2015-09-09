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
          redirect_to issues_path( :project_id => @pref.landing_page.gsub("p-","").to_i )
        elsif @pref.landing_page.start_with?('q-')
          query_id = @pref.landing_page.gsub("q-","").to_i
          query = IssueQuery.find_by_id(query_id)
          return if query.nil?
          param_hash = query.project_id.nil? ? { :query_id => query_id } : { :project_id => query.project_id, :query_id => query_id }
          redirect_to issues_path( param_hash )
        elsif @pref.landing_page.start_with?('my_page')
          redirect_to my_page_path
        end
      end
    end
  end
end
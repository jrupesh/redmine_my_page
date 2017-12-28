module MyPagePatches
  class RedmineMyPageHook < Redmine::Hook::ViewListener
    def view_users_form_preferences(context={})
      user_langing_page_options(context)
    end

    def view_my_account_preferences(context={})
      user_langing_page_options(context)
    end

    def controller_account_success_authentication_after(context={})
      return unless context[:user].present?

      pref = context[:user].pref
      return if pref.landing_page.nil? || pref.landing_page.blank?

      begin
        cur_back_url = URI.parse(context[:hook_caller].params['back_url'])
        return unless cur_back_url.path == home_url
      rescue
        Rails.logger.debug('redmine_my_page: Invalid back URL')
      end
      ret_url = MypageHelper::user_pref_url(self, pref)
      context[:hook_caller].params['back_url'] = ret_url if ret_url.present?
    end

    def user_langing_page_options(context)
      user  = context[:user]
      f     = context[:form]
      s     = ''

      # List all the landing pages after login.
      # 1) Issue List of a project
      # 2) Custom Query Issue List.
      # 3) My Page
      projects = Project.active.visible.sorted.includes(:enabled_modules).
          select { |p| p if p.module_enabled?("issue_tracking") }

      selection_options = [[l(:label_default_my_page), [ [l(:label_my_page), "my_page"]] + projects.
                    map { |p| ["#{l(:label_overview)} - #{p.name}", "o-#{p.id}" ] } ]]
      selection_options += [[ l(:label_project_issues), projects.
                    map { |p| ["#{p.name}", "p-#{p.id}" ] }]]
      selection_options += [[ l(:label_query), IssueQuery.visible.
                    pluck(:name,:id).map { |name,id| ["#{name}", "q-#{id}" ] }]]

      # Add to select options the Agile project tabs if plugin exists.
      if Redmine::Plugin.installed?(:redmine_agile)
        agile_projects = Project.active.visible.sorted.includes(:enabled_modules).
            select { |p| p if p.module_enabled?("agile") }
        selection_options += [[ "#{l(:label_agile)} #{l(:field_project)}" , agile_projects.
                      map { |p| ["#{p.name}", "ap-#{p.id}" ] }]] if agile_projects.any?
        selection_options += [[ l(:label_agile_board), AgileQuery.visible.
                      pluck(:name,:id).map { |name,id| ["#{name}", "aq-#{id}" ] }]] if AgileQuery.visible.any?
      end

      # Add to select options the Dashboard project tabs if plugin exists.
      if Redmine::Plugin.installed?(:redmine_dashboard)
        rdb_projects = Project.active.visible.sorted.includes(:enabled_modules).
            select { |p| p if p.module_enabled?("dashboard") }
        selection_options += [[ "#{l(:project_module_dashboard)} #{l(:field_project)}" , rdb_projects.
                      map { |p| ["#{p.name}", "rdb-#{p.id}" ] }]] if rdb_projects.any?
      end

      s << "<p>"
      s << label_tag( "pref_landing_page", l(:label_landing_page) )
      s << select_tag( "pref[landing_page]", grouped_options_for_select(selection_options,
                    selected_key = user.pref.landing_page ), :id => 'pref_landing_page', :include_blank => true )
      s << "</p>"

      return s.html_safe
    end
  end
end

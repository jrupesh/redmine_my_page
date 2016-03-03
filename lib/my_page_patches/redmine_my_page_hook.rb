module MyPagePatches
  class RedmineMyPageHook < Redmine::Hook::ViewListener
    def view_users_form_preferences(context={})
      user_langing_page_options(context)
    end

    def view_my_account_preferences(context={})
      user_langing_page_options(context)
    end

    def user_langing_page_options(context)
      user  = context[:user]
      f     = context[:form]
      s     = ''

      # List all the landing pages after login.
      # 1) Issue List of a project
      # 2) Custom Query Issue List.
      # 3) My Page
      projects = Project.visible.includes(:enabled_modules).
          select { |p| p if p.module_enabled?("issue_tracking") }

      selection_options = [[l(:label_default_my_page), [ [l(:label_my_page), "my_page"]] + projects.
                    map { |p| ["Overview - #{p.name}", "o-#{p.id}" ] } ]]
      selection_options += [[ 'Issue List of Project', projects.
                    map { |p| ["#{p.name}", "p-#{p.id}" ] }]]
      selection_options += [[ 'Custom Query', IssueQuery.where( :user_id => User.current.id, :project_id => Project.visible.pluck(:id) ).
                    pluck(:name,:id).map { |name,id| ["#{name}", "q-#{id}" ] }]]

      s << "<p>"
      s << label_tag( "pref_landing_page", l(:label_landing_page) )
      s << select_tag( "pref[landing_page]", grouped_options_for_select(selection_options,
                    selected_key = user.pref.landing_page ), :id => 'pref_landing_page', :include_blank => true )
      s << "</p>"

      return s.html_safe
    end
  end
end

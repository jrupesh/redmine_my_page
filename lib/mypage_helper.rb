module MypageHelper
  def self.user_pref_url(view, pref)
    ret_url = nil
    if pref.landing_page.start_with?('o-')
      ret_url = view.project_url( :id => pref.landing_page.gsub("o-","").to_i )
    elsif pref.landing_page.start_with?('p-')
      home_project = Project.find_by_id(pref.landing_page.gsub("p-","").to_i)
      return if home_project.nil? || home_project.archived?
      ret_url = view.issues_url( :project_id => home_project.id )
    elsif pref.landing_page.start_with?('q-')
      query_id = pref.landing_page.gsub("q-","").to_i
      query = IssueQuery.find_by_id(query_id)
      return if query.nil?
      param_hash = query.project_id.nil? ? { :query_id => query_id } : { :project_id => query.project_id, :query_id => query_id }
      ret_url = view.issues_url( param_hash )
    elsif pref.landing_page.start_with?('my_page')
      ret_url = view.my_page_url
    end
    return ret_url if ret_url.present?
    if Redmine::Plugin.installed?(:redmine_agile)
      if pref.landing_page.start_with?('ap-')
        home_project = Project.find_by_id(pref.landing_page.gsub("ap-","").to_i)
        return if home_project.nil? || home_project.archived?
        ret_url = view.agile_board_url( :project_id => home_project.id )
      elsif pref.landing_page.start_with?('aq-')
        query_id = pref.landing_page.gsub("aq-","").to_i
        query = AgileQuery.find_by_id(query_id)
        return if query.nil?
        param_hash = query.project_id.nil? ? { :query_id => query_id } : { :project_id => query.project_id, :query_id => query_id }
        ret_url = view.agile_board_url( param_hash )
      end
    end
    if Redmine::Plugin.installed?(:redmine_dashboard)
      if pref.landing_page.start_with?('rdb-')
        home_project = Project.find_by_id(pref.landing_page.gsub("rdb-","").to_i)
        return if home_project.nil? || home_project.archived?
        ret_url = view.rdb_taskboard_url( :id => home_project.id )
      end
    end
    ret_url
  end
end

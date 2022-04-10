require File.expand_path('../lib/my_page_patches/redmine_my_page_hook', __FILE__)

Redmine::Plugin.register :redmine_my_page do
  name 'My Page Customization'
  author 'Rupesh J'
  description 'Adds additional options to the My Page of users.\nCustom Queries and Activities ( filtered ) will be shown in a single page.'
  version '0.1.13'

  requires_redmine :version_or_higher => '3.4.0'

  settings :default => { 'my_activity_enable' => 0, 'homelink_override' => 1 },
            :partial => 'settings/my_page_option_settings'

  menu :top_menu, :my_landing_page, { controller: 'welcome', action: 'index', force_redirect: 1},
       :caption => :label_my_landing_page,
       :if => Proc.new { Setting.plugin_redmine_my_page["homelink_override"] != "1" &&
          User.current.pref.landing_page.present? && !User.current.pref.landing_page.start_with?('my_page') }
end

if Rails.version > '6.0' && Rails.autoloaders.zeitwerk_enabled?
  Rails.application.config.after_initialize do
    RedmineMyPage.setup
  end
else
  Rails.configuration.to_prepare do
    RedmineMyPage.setup
  end
end

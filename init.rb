require 'redmine'
require 'patches/my_controller_patch'
require 'patches/activities_controller_patch'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'hooks/redmine_my_page_hook'
end

Redmine::Plugin.register :redmine_my_page do
  name 'My Page Customization'
  author 'Rupesh J'
  description 'Adds additional options to the My Page of users.\nCustom Queries and Activities ( filtered ) will be shown in a single page.'
  version '0.1.3'

  settings :default => { 'my_activity_enable' => false },
            :partial => 'settings/my_page_option_settings'

  Rails.configuration.to_prepare do
    MyController.send :include, Patches::MyControllerPatch
    ActivitiesController.send(:include, Patches::ActivitiesControllerPatch)
    WelcomeController.send(:include, Patches::WelcomeControllerPatch)

    UserPreference.send(:include, Patches::UserPreferencePatch)
  end
end

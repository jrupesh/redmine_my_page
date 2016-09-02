require 'redmine'
require 'my_page_patches/my_controller_patch'
require 'my_page_patches/activities_controller_patch'
require 'my_page_patches/user_preference_patch'
require 'my_page_patches/welcome_controller_patch'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'my_page_patches/redmine_my_page_hook'
end

Redmine::Plugin.register :redmine_my_page do
  name 'My Page Customization'
  author 'Rupesh J'
  description 'Adds additional options to the My Page of users.\nCustom Queries and Activities ( filtered ) will be shown in a single page.'
  version '0.1.10'

  settings :default => { 'my_activity_enable' => false },
            :partial => 'settings/my_page_option_settings'

  Rails.configuration.to_prepare do
    MyController.send :include, MyPagePatches::MyControllerPatch
    ActivitiesController.send(:include, MyPagePatches::ActivitiesControllerPatch)
    WelcomeController.send(:include, MyPagePatches::WelcomeControllerPatch)
    UserPreference.send(:include, MyPagePatches::UserPreferencePatch)
  end
end

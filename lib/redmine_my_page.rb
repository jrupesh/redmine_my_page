module RedmineMyPage
  def self.setup
    MyController.send :include, MyPagePatches::MyControllerPatch
    ActivitiesController.send(:include, MyPagePatches::ActivitiesControllerPatch)
    WelcomeController.send(:include, MyPagePatches::WelcomeControllerPatch)
    UserPreference.send(:include, MyPagePatches::UserPreferencePatch)
  end
end

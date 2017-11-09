module MyPagePatches
  module WelcomeControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
        before_filter :landing_page_index, :only => :index
      end
    end

    module InstanceMethods
      def landing_page_index
        if User.current.logged? && ((Setting.plugin_redmine_my_page["homelink_override"] == "1" &&
            User.current.pref.landing_page.present?) || params['force_redirect'] == '1')

          ret_url = MypageHelper::user_pref_url(self, User.current.pref)
          redirect_to ret_url if ret_url.present?
        end
      end
    end
  end
end
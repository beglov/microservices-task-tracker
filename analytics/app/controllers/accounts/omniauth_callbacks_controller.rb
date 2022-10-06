module Accounts
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def doorkeeper
      @account = Account.from_omniauth(request.env["omniauth.auth"])

      if @account.persisted?
        sign_in_and_redirect @account, event: :authentication
        set_flash_message(:notice, :success, kind: "Doorkeeper") if is_navigational_format?
      else
        session["devise.doorkeeper_data"] = request.env["omniauth.auth"]
        redirect_to new_account_session_path
      end
    end
  end
end

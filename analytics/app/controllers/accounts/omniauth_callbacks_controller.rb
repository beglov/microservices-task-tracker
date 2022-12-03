module Accounts
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def doorkeeper
      result = AuthService.new(request.env["omniauth.auth"]).call

      if result.success?
        success_auth_response(result)
      else
        failure_auth_response(result)
      end
    end

    private

    def success_auth_response(result)
      sign_in_and_redirect result.success, event: :authentication
      set_flash_message(:notice, :success, kind: "Doorkeeper") if is_navigational_format?
    end

    def failure_auth_response(result)
      message = result.failure
      flash[:notice] = message if message.present?
      session["devise.doorkeeper_data"] = request.env["omniauth.auth"]
      redirect_to new_account_session_path
    end
  end
end

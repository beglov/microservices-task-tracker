class Account < ApplicationRecord
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: %i[doorkeeper]

  def self.from_omniauth(auth)
    Rails.logger.debug "=" * 80
    Rails.logger.debug auth
    Rails.logger.debug "=" * 80
    where(provider: auth.provider, uid: auth.uid).first_or_create do |account|
      account.public_id = auth.info.public_id
      account.full_name = auth.info.full_name
      account.email = auth.info.email
      account.role = auth.info.role
    end
  end

  def worker?
    role == "worker"
  end
end

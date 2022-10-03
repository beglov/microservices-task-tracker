class Account < ApplicationRecord
  devise :database_authenticatable,
         :omniauthable, omniauth_providers: %i[doorkeeper]

  def self.from_omniauth(auth)
    Rails.logger.debug "=" * 80
    Rails.logger.debug auth
    Rails.logger.debug "=" * 80
    where(public_id: auth.info.public_id).first_or_create do |account|
      account.full_name = auth.info.full_name
      account.email = auth.info.email
      account.role = auth.info.role
      account.provider = auth.provider
      account.uid = auth.uid
    end
  end

  def worker?
    role == "worker"
  end
end

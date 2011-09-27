class Users::SessionsController < Devise::SessionsController

  def new
    if Errbit::Config.github_organizations.present?
      redirect_to user_omniauth_authorize_path(:github) 
    else
      super
    end
  end
  
end
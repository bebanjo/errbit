class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def github
    omniauth = env['omniauth.auth']
    user = User.where(:github_username => omniauth['user_info']['nickname']).first
    if user
      sign_in_and_redirect :user, user
    else
      flash[:alert] = 'Github username not found'
      redirect_to new_session_path(:user)
    end  
  end
end

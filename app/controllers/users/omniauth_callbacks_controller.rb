# encoding: UTF-8

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def github
    if authorized_organizations.any?
      sign_in_and_redirect :user, find_or_create_user
    else
      flash[:alert] = 'You don’t belong to any authorized organization'
      redirect_to new_session_path(:user)
    end  
  end
  
  private
  
  def omniauth
    @omniauth ||= env['omniauth.auth']
  end
  
  def client
    @client ||= Octokit::Client.new(:login => omniauth['user_info']['nickname'], 
                                    :oauth_token => omniauth['credentials']['token'])
  end
  
  def find_or_create_user
    User.find_or_initialize_by(:github_username => omniauth['user_info']['nickname']).tap do |user|
      user.admin = github_admin? 
      user.update_attributes! omniauth['user_info'].slice('name', 'email')
    end
  end
  
  def authorized_organizations
    @authorized_organizations ||= client.organizations.select do |o| 
      Errbit::Config.github_organizations.include?(o.login)
    end
  end
  
  def github_admin?
    authorized_organizations.any? do |organization|
      organization_admin?(organization)
    end
  end
  
  def organization_admin?(organization)
    client.organization_teams(organization.login).any? do |team|
      team_admin?(team)
    end
  end
  
  def team_admin?(team)
    team.permission == 'admin' && team_member?(team)
  end
  
  def team_member?(team)
    client.team_members(team.id).any? do |member|
      member.login == omniauth['user_info']['nickname']
    end
  end
end

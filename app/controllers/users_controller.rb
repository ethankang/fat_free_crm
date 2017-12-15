# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class UsersController < ApplicationController
  before_action :set_current_tab, only: [:show, :opportunities_overview] # Don't hightlight any tabs.

  check_authorization
  load_and_authorize_resource # handles all security

  respond_to :html, only: [:show, :new]

  # GET /users/1
  # GET /users/1.js
  #----------------------------------------------------------------------------
  def show
    @user = current_user if params[:id].nil?
    respond_with(@user)
  end

  # GET /users/new
  # GET /users/new.js
  #----------------------------------------------------------------------------
  def new
    respond_with(@user)
  end

  # POST /users
  # POST /users.js
  #----------------------------------------------------------------------------
  def create
    if @user.save
      if Setting.user_signup == :needs_approval
        flash[:notice] = t(:msg_account_created)
        redirect_to login_url
      else
        flash[:notice] = t(:msg_successful_signup)
        redirect_back_or_default profile_url
      end
    else
      render :new
    end
  end

  # GET /users/1/edit.js
  #----------------------------------------------------------------------------
  def edit
    respond_with(@user)
  end

  # PUT /users/1
  # PUT /users/1.js
  #----------------------------------------------------------------------------
  def update
    @user.update_attributes(user_params)
    respond_with(@user)
  end

  # GET /users/1/avatar
  # GET /users/1/avatar.js
  #----------------------------------------------------------------------------
  def avatar
    respond_with(@user)
  end

  # PUT /users/1/upload_avatar
  # PUT /users/1/upload_avatar.js
  #----------------------------------------------------------------------------
  def upload_avatar
    if params[:gravatar]
      @user.avatar = nil
      @user.save
      render
    else
      if params[:avatar]
        avatar = Avatar.create(avatar_params)
        if avatar.valid?
          @user.avatar = avatar
        else
          @user.avatar.errors.clear
          @user.avatar.errors.add(:image, t(:msg_bad_image_file))
        end
      end
      responds_to_parent do
        # Without return RSpec2 screams bloody murder about rendering twice:
        # within the block and after yield in responds_to_parent.
        render && (return if Rails.env.test?)
      end
    end
  end

  # GET /users/1/password
  # GET /users/1/password.js
  #----------------------------------------------------------------------------
  def password
    respond_with(@user)
  end

  # PUT /users/1/change_password
  # PUT /users/1/change_password.js
  #----------------------------------------------------------------------------
  def change_password
    if @user.valid_password?(params[:current_password], true) || @user.password_hash.blank?
      if params[:user][:password].blank?
        flash[:notice] = t(:msg_password_not_changed)
      else
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        @user.save
        flash[:notice] = t(:msg_password_changed)
      end
    else
      @user.errors.add(:current_password, t(:msg_invalid_password))
    end

    respond_with(@user)
  end

  # GET /users/1/redraw
  #----------------------------------------------------------------------------
  def redraw
    current_user.preference[:locale] = params[:locale]
    render js: %(window.location.href = "#{user_path(current_user)}";)
  end

  # GET /users/opportunities_overview
  #----------------------------------------------------------------------------
  def opportunities_overview
    @users_with_opportunities = User.have_assigned_opportunities.order(:first_name)
    @unassigned_opportunities = Opportunity.my.unassigned.pipeline.order(:stage)
  end

  # 团队总线索数、总商机额整合
  def team_overview
    @team_users = Group.find_by_name(Setting.sales_group_name).users.active
    set_current_tab('team_overview')
  end

  # 根据不同type redirect_to
  def entity_redirection
    table_name,user_id ,search_params = params[:type],params[:id],""
    redirect_to "/tasks/index_by_user/#{user_id}" and return if table_name == 'tasks'
    search_params = {"utf8"=>"✓", "q"=>{"s"=>{"0"=>{"name"=>"created_at", "dir"=>"desc"}},
                                        "g"=>{"0"=>{"m"=>"or", "c"=>{"0"=>{"a"=>{"0"=>{"name"=>"user_id"}},
                                        "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}},
                                        "1"=>{"a"=>{"0"=>{"name"=>"assigned_to"}}, "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}}}}}},
                     "distinct"=>"1", "page"=>"1"}


    if table_name.include?("converted")
      search_params =  {"utf8"=>"✓", "q"=>{"s"=>{"0"=>{"name"=>"created_at", "dir"=>"desc"}},
                                           "g"=>{"0"=>{"m"=>"or", "c"=>{"0"=>{"a"=>{"0"=>{"name"=>"user_id"}},
                                           "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}}, "1"=>{"a"=>{"0"=>{"name"=>"assigned_to"}},
                                           "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}}}}, "2"=>{"m"=>"and", "c"=>{"0"=>{"a"=>{"0"=>{"name"=>"converted_at"}},
                                           "p"=>"gt", "v"=>{"0"=>{"value"=>"#{Time.current.beginning_of_day}"}}}, "3"=>{"a"=>{"0"=>{"name"=>"converted_at"}},
                                           "p"=>"lt", "v"=>{"0"=>{"value"=>"#{Time.current.end_of_day}"}}},"4" =>{"a"=>{"0"=>{"name"=>"converted_operate_id"}},
                                           "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}}}}}}, "distinct"=>"1", "page"=>"1"}
    elsif table_name == 'day_leads'
      search_params =  {"utf8"=>"✓", "q"=>{"s"=>{"0"=>{"name"=>"created_at", "dir"=>"desc"}},
                                          "g"=>{"0"=>{"m"=>"or", "c"=>{"0"=>{"a"=>{"0"=>{"name"=>"user_id"}},
                                          "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}}, "1"=>{"a"=>{"0"=>{"name"=>"assigned_to"}},
                                          "p"=>"eq", "v"=>{"0"=>{"value"=>"#{user_id}"}}}}}, "2"=>{"m"=>"and", "c"=>{"0"=>{"a"=>{"0"=>{"name"=>"created_at"}},
                                          "p"=>"gt", "v"=>{"0"=>{"value"=>"#{Time.current.beginning_of_day}"}}}, "3"=>{"a"=>{"0"=>{"name"=>"created_at"}},
                                          "p"=>"lt", "v"=>{"0"=>{"value"=>"#{Time.current.end_of_day}"}}}}}}}, "distinct"=>"1", "page"=>"1"}


    end
    redirect_to "/#{table_name.split("_").last}?"+ search_params.to_query
  end
  protected

  def user_params
    params[:user][:email].try(:strip!)
    params[:user].permit(
      :username,
      :email,
      :first_name,
      :last_name,
      :title,
      :company,
      :alt_email,
      :phone,
      :mobile,
      :aim,
      :yahoo,
      :google,
      :skype
    )
  end

  def avatar_params
    params[:avatar]
      .permit(:image)
      .merge(entity: @user)
  end
end

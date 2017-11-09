# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class AuthenticationsController < ApplicationController
  before_action :require_no_user, only: [:new, :create, :new_by_dingtalk, :create_by_dingtalk, :show]
  before_action :require_user, only: :destroy

  #----------------------------------------------------------------------------
  def new
    @authentication = Authentication.new
  end

  def new_by_dingtalk
    render layout: false
  end

  def create_by_dingtalk
    if params[:code] && result = Dingtalk.api.getuserinfo(params[:code])
      Rails.logger.info("result: #{result}")

      if result['errcode'] == 0 && dingid = result['userid']
        if user = User.find_by(dingid: dingid)
          @authentication = Authentication.new(user)
          @authentication.save && !@authentication.user.suspended?
        else
          # 没有找到该dingid对应的user
          # 将dingid存在cookies,便于用户名和密码登录时更新dingid
          cookies[:dingid] = dingid
        end
      end
    end

    render :redirect_to_home
  end

  #----------------------------------------------------------------------------
  def show
    redirect_to login_url
  end

  #----------------------------------------------------------------------------
  def create
    @authentication = Authentication.new(params[:authentication])

    if @authentication.save && !@authentication.user.suspended?
      # 若登录用户的dingid为空，从cookies中获取dingid更新
      @authentication.user.update(dingid: cookies.delete(:dingid)) unless @authentication.user.dingid

      flash[:notice] = t(:msg_welcome)
      if @authentication.user.login_count > 1 && @authentication.user.last_login_at?
        flash[:notice] << " " << t(:msg_last_login, l(@authentication.user.last_login_at, format: :mmddhhss))
      end
      redirect_back_or_default root_url
    else
      if @authentication.user && @authentication.user.awaits_approval?
        flash[:notice] = t(:msg_account_not_approved)
      else
        flash[:warning] = t(:msg_invalig_login)
      end
      redirect_to action: :new
    end
  end

  # The login form gets submitted to :update action when @authentication is
  # saved (@authentication != nil) but the user is suspended.
  #----------------------------------------------------------------------------
  alias_method :update, :create

  #----------------------------------------------------------------------------
  def destroy
    current_user_session.destroy
    flash[:notice] = t(:msg_goodbye)
    redirect_back_or_default login_url
  end
end

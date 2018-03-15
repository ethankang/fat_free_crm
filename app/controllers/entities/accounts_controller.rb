# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class AccountsController < EntitiesController
  before_action :get_data_for_sidebar, only: :index

  # GET /accounts
  #----------------------------------------------------------------------------
  def index
    # 将get_accounts即get_list_of_records暂时移动过来，简单修改看是否在查询速度上有大的提升
    # get_accounts begin
    options = {page: params[:page], per_page: params[:per_page]}
    options[:query]  ||= params[:query]                        if params[:query]
    self.current_page  = options[:page]                        if options[:page]
    query, tags        = parse_query_and_tags(options[:query])
    self.current_query = query
    advanced_search = params[:q].present?
    wants = request.format

    scope = entities.merge(ransack_search.result(distinct: true))

    # Get filter from session, unless running an advanced search
    unless advanced_search
      filter = session[:"#{controller_name}_filter"].to_s.split(',')
      scope = scope.state(filter) if filter.present?
    end

    scope = scope.text_search(query)              if query.present?
    scope = scope.tagged_with(tags, on: :tags) if tags.present?

    # Ignore this order when doing advanced search
    unless advanced_search
      order = current_user.pref[:"#{controller_name}_sort_by"] || klass.sort_by
      scope = scope.order(order)
    end

    @search_results_count = scope.count

    # 计算应该有未完成的任务的,但是却没有未完成任务accounts
    @requared_tasks_count = scope.requared_tasks_no_task.length

    #include 所有的关联的contacts, task, opportunities, comments和user
    scope = scope.includes(
      :contacts, :tasks,
      opportunities: :user,
      comments: :user
    )

    # Pagination is disabled for xls and csv requests
    unless wants.xls? || wants.csv?
      per_page = if options[:per_page]
                   options[:per_page] == 'all' ? @search_results_count : options[:per_page]
                 else
                   current_user.pref[:"#{controller_name}_per_page"]
      end
      scope = scope.paginate(page: current_page, per_page: per_page)
    end

    scope
    ### get_accounts end

    # @accounts = get_accounts(page: params[:page], per_page: params[:per_page])
    @accounts = scope

    respond_with @accounts do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @accounts }
    end
  end

  def tasks_required
    set_options

    per_page =
      if params[:per_page]
        params[:per_page] == 'all' ? @search_results_count : params[:per_page]
      else
        current_user.pref[:"#{controller_name}_per_page"]
      end

    @accounts = entities.merge(ransack_search.result(distinct: true)). requared_tasks_no_task
    @search_results_count = @accounts.length
    @requared_tasks_count = @accounts.requared_tasks_no_task.length
    @accounts = @accounts.paginate(page: current_page, per_page: per_page)

    render :index
  end

  # GET /accounts/1
  # AJAX /accounts/1
  #----------------------------------------------------------------------------
  def show
    @stage = Setting.unroll(:opportunity_stage)
    @comment = Comment.new
    @timeline = timeline(@account)
    respond_with(@account)
  end

  # GET /accounts/new
  #----------------------------------------------------------------------------
  def new
    @account.attributes = { user: current_user, access: Setting.default_access, assigned_to: nil }

    if params[:related]
      model, id = params[:related].split('_')
      instance_variable_set("@#{model}", model.classify.constantize.find(id))
    end

    respond_with(@account)
  end

  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@account)
  end

  # POST /accounts
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]
    respond_with(@account) do |_format|
      if @account.save
        @account.add_comment_by_user(@comment_body, current_user)
        # None: account can only be created from the Accounts index page, so we
        # don't have to check whether we're on the index page.
        @accounts = get_accounts
        get_data_for_sidebar
      end
    end
  end

  # PUT /accounts/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@account) do |_format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @account.access = params[:account][:access] if params[:account][:access]
      get_data_for_sidebar if @account.update_attributes(resource_params)
    end
  end

  # DELETE /accounts/1
  #----------------------------------------------------------------------------
  def destroy
    @account.destroy

    respond_with(@account) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /accounts/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /accounts/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /accounts/auto_complete/query                                     AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # GET /accounts/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:accounts_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:accounts_sort_by]  = Account.sort_by_map[params[:sort_by]] if params[:sort_by]
    @accounts = get_accounts(page: 1, per_page: params[:per_page])
    set_options # Refresh options

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  # POST /accounts/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:accounts_filter] = params[:category]
    @accounts = get_accounts(page: 1, per_page: params[:per_page])

    respond_with(@accounts) do |format|
      format.js { render :index }
    end
  end

  private

  #----------------------------------------------------------------------------
  alias_method :get_accounts, :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @accounts = get_accounts
      get_data_for_sidebar
      if @accounts.empty?
        @accounts = get_accounts(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
      # At this point render default destroy.js
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @account.name)
      redirect_to accounts_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @account_category_total = HashWithIndifferentAccess[
                              Setting.account_category.map do |key|
                                [key, Account.my.where(category: key.to_s).count]
                              end
    ]
    categorized = @account_category_total.values.sum
    @account_category_total[:all] = Account.my.count
    @account_category_total[:other] = @account_category_total[:all] - categorized
  end
end

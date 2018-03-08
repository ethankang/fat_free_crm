# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CommentsController < EntitiesController
  before_action :get_data_for_sidebar, only: :index

  # GET /comments
  #----------------------------------------------------------------------------
  def index
    @comments = get_comments(page: params[:page], per_page: params[:per_page])

    respond_with @comments do |format|
      format.xls { render layout: 'header' }
      format.csv { render csv: @comments }
    end
  end

  # GET /comments/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Comment.my.find_by_id(Regexp.last_match[1]) || Regexp.last_match[1].to_i
    end

    respond_with(@comment)
  end

  # POST /comments
  #----------------------------------------------------------------------------
  def create
    @comment = Comment.new(
      comment_params.merge(user_id: current_user.id)
    )
    # Make sure commentable object exists and is accessible to the current user.
    model = @comment.commentable_type
    id = @comment.commentable_id
    if model.constantize.my.find_by_id(id)
      @comment.save
      respond_with(@comment)
    else
      respond_to_related_not_found(model.downcase)
    end
  end

  # PUT /comments/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@comment) do |_format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @comment.access = params[:comment][:access] if params[:comment][:access]
      get_data_for_sidebar if @comment.update_attributes(resource_params)
    end
  end

  # DELETE /comments/1
  #----------------------------------------------------------------------------
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    respond_with(@comment)
  end

  # GET /comments/redraw                                                   AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:comments_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:comments_sort_by]  = Comment.sort_by_map[params[:sort_by]] if params[:sort_by]
    @comments = get_comments(page: 1, per_page: params[:per_page])
    set_options # Refresh options

    respond_with(@comments) do |format|
      format.js { render :index }
    end
  end

  # POST /comments/filter                                                  AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:comments_filter] = params[:category]
    @comments = get_comments(page: 1, per_page: params[:per_page])

    respond_with(@comments) do |format|
      format.js { render :index }
    end
  end

  private

  #----------------------------------------------------------------------------
  alias_method :get_comments, :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      @comments = get_comments
      get_data_for_sidebar
      if @comments.empty?
        @comments = get_comments(page: current_page - 1) if current_page > 1
        render(:index) && return
      end
      # At this point render default destroy.js
    else # :html request
      self.current_page = 1 # Reset current page to 1 to make sure it stays valid.
      flash[:notice] = t(:msg_asset_deleted, @comment.name)
      redirect_to comments_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
  end

  def comment_params
    params[:comment].permit!
  end
end

class ImagePostController < ApplicationController
  def index
    @posts = posts_filtered_by_dimensions

    if params[:page] && params[:page].to_i > 1
      p = params[:page].to_i * 24
      @previous_page_valid = true if @posts.count > 24
      @next_page_valid = true if @posts.count > p
      @posts = @posts.order('score DESC')[p-24..p-1]
    else
      @next_page_valid = true if @posts.count > 24
      @posts = @posts.order('score DESC').first(24)
    end

    params[:refresh_status] = ImagePost.refresh_status
    params[:min_since_refresh] = ImagePost.min_since_last_refresh
  end

  def refresh
    RefreshBlock.create
    ImagePost.delay.refresh_posts
    redirect_to root_path
  end


  private


  def posts_filtered_by_dimensions
    posts = ImagePost.all
    return posts unless params[:height].present? && params[:width].present?
    posts.where(width: params[:width], height: params[:height])
  end

end

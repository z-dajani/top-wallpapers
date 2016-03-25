class ImagePostController < ApplicationController
  def index
    if params[:page] && params[:page].to_i > 1
      p = params[:page].to_i * 24
      @posts = ImagePost.order('score DESC')[p-24..p-1]
      @previous_page_valid = true if ImagePost.count > 24
      @next_page_valid = true if ImagePost.count > p
    else
      @posts = ImagePost.order('score DESC').first(24)
      @next_page_valid = true if ImagePost.count > 24
    end
    params[:refresh_status] = ImagePost.refresh_status
    params[:min_since_refresh] = ImagePost.min_since_last_refresh

  end

  def refresh
    RefreshBlock.create
    ImagePost.delay.refresh_posts
    redirect_to root_path
  end

end

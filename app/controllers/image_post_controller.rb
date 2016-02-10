class ImagePostController < ApplicationController
  def index
    if params[:page] && params[:page].to_i > 1
      p = params[:page].to_i * 20
      @posts = ImagePost.order('score DESC')[p-20..p-1]
      @previous_page_valid = true if ImagePost.count > 20
      @next_page_valid = true if ImagePost.count > p
    else
      @posts = ImagePost.order('score DESC').first(20)
      @next_page_valid = true if ImagePost.count > 20
    end
    params[:refresh_status] = ImagePost.refresh_status
    params[:minutes_since_refresh] = ImagePost.minutes_since_last_refresh

  end

  def refresh
    ImagePost.delay.refresh_posts
    flash[:refreshing_msg] = true
    redirect_to root_path
  end

end

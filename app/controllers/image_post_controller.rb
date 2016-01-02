class ImagePostController < ApplicationController
  def index
    @posts = ImagePost.order('score DESC')
  end
  
end

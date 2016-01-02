class ImagePostController < ApplicationController
  def index
    @posts = ImagePost.all
  end
  
end

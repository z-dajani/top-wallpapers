ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def valid_image_post(save: true)
    seed = (ImagePost.any?) ? ImagePost.last.id : 'a123'
    p = ImagePost.new(title: 'Space Shuttle', subreddit: 'wallpapers',
                      score: 173, url: "http://i.imgur.com/#{seed}",
                      thumbnail: "http://thumbs.redditmedia.com/#{seed}", 
                      permalink:"/r/wallpapers/comments/abc/#{seed}/")
    p.save if save
    p
  end

end
